######################################################################
## Create the VPC and tag it
###

resource "aws_vpc" "vpc" {
    cidr_block           = "${var.vpc_cidr}"
    enable_dns_support   = 1
    instance_tenancy = "default"
    enable_dns_hostnames = 1
    tags                 = {
                             "Name"    = "${var.env}-environment-vpc"
                             "owner"   = "${var.owner}"
                             "email"   = "${var.email}"
                             "group"   = "${var.group}"
                             "env"     = "${var.env}"
                           }
}

 

######################################################################
## Set up Internet Gateway
###

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags   = {
               "Name"  = "${var.env}-environment-igw"
               "owner" = "${var.owner}"
               "email" = "${var.email}"
               "group" = "${var.group}"
               "env"   = "${var.env}"
             }
}


######################################################################
## Setup Private Subnets
###

resource "aws_subnet" "priv" {
   vpc_id                  = "${aws_vpc.vpc.id}"
   count                   = "${var.pri_count}"
   cidr_block              = "${cidrsubnet(var.vpc_cidr, 4, count.index + var.pri_offset)}"
   availability_zone       = "${element(split(",", var.availability_zones), count.index)}"
   map_public_ip_on_launch = false
   tags                    = {
                               "Name"        = "${var.env}-priv-${count.index}"
                               "owner"       = "${var.owner}"
                               "email"       = "${var.email}"
                               "group"       = "${var.group}"
                               "env"         = "${var.env}"
                               "NetworkType" = "private"
                             }

}


######################################################################
## Public Subnets
###

resource "aws_subnet" "public" {
   vpc_id                  = "${aws_vpc.vpc.id}"
   count                   = "${var.pub_count}"
   cidr_block              = "${cidrsubnet(var.vpc_cidr, 4, count.index + var.pub_offset)}"
   availability_zone      = "${element(split(",", var.availability_zones), count.index)}"
   tags                    = {
                               "Name"        = "${var.env}-public-${count.index}"
                               "owner"       = "${var.owner}"
                               "email"       = "${var.email}"
                               "group"       = "${var.group}"
                               "env"         = "${var.env}"
                               "NetworkType" = "public"
                             }
  map_public_ip_on_launch = true

}


#####################################################################
## Route table for public subnets
###

resource "aws_route_table" "public-route-table" {
   vpc_id = "${aws_vpc.vpc.id}"
   tags   = {
              "Name"  = "${var.env} Public Route Table"
              "owner" = "${var.owner}"
              "email" = "${var.email}"
              "group" = "${var.group}"
              "env"   = "${var.env}"
              "NetworkType" = "public"
             }
                 lifecycle {
    ignore_changes = [
      "propagating_vgws"
    ]
  }
}

   resource "aws_route" "pub_default" {
    route_table_id = "${aws_route_table.public-route-table.id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
}
######################################################################
## Set up NAT gateway and elastic IP addresses for NAT gateways
###

resource "aws_eip" "nat" {
  vpc   = true
  count = "${var.nat_gateways_count}"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  count         = "${var.nat_gateways_count}"
  depends_on = ["aws_internet_gateway.igw"]
}

######################################################################
## for each private subnet seup up a private route table
###

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  count  = "${var.pri_count}"
  tags {
    				Name = "${var.env}-private_route_table.${element(split(",", var.availability_zones), count.index)}"
                               "owner"       = "${var.owner}"
                               "email"       = "${var.email}"
                               "group"       = "${var.group}"
                               "env"         = "${var.env}"
                               "NetworkType" = "private"
  }

    lifecycle {
    ignore_changes = [
      "propagating_vgws"
    ]
  }
}


#####################################################################
## for each private subnet network route table add a nat gateway 
###

resource "aws_route" "nat_gateway" {
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  count                  = "${var.pri_count}"
  depends_on             = ["aws_route_table.private"]
}

#####################################################################
## Add a custom route association to each range too
### 

resource "aws_route_table_association" "private" {
  subnet_id      = "${element(aws_subnet.priv.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  count          = "${var.pri_count}"
}


resource "aws_route_table_association" "public-rtb" {
   count          = "${var.pub_count}"
   subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
   route_table_id = "${aws_route_table.public-route-table.id}"
}
