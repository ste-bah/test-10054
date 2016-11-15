######################################################################
# Output vars
##
output "private_subnet_ids" {
  value = "${join(",",aws_subnet.priv.*.id)}"
}
output "private_subnet_cidrs" {
  value = "${join(",",aws_subnet.priv.*.cidr_block)}" 
}
output "igw_id" {
   value = "${aws_internet_gateway.igw.id}"
}

output "vpc_name" {
    value = "${aws_vpc.vpc.tags.Name}"
}

output "vpc_id" {
   value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr" {
   value = "${var.vpc_cidr}"
}

output "consul_subnet_ids" {
 value = ["${aws_subnet.public.*.id}"]
}

output "public_subnet_ids" {
 value = "${join(",",aws_subnet.public.*.id)}"
}

output "public_subnet_cidrs" {
 value = "${join(",",aws_subnet.public.*.cidr_block)}"
}

output "private_route_table_ids" {
  value = "${join(",",aws_route_table.private.*.id)}"
}

output "public_route_table_id" {
   value = "${aws_route_table.public-route-table.id}"
}

output "pub_rtbl_assoc_ids" {
   value = "${join(",",aws_route_table_association.public-rtb.*.id)}"
}

output "nat_eips" {
  value = "${join(",",aws_eip.nat.*.public_ip)}"
}

output "default_security_group" {
  value = "${aws_vpc.vpc.default_security_group_id}"
}

output "availability_zones" {
  value = "${join(",",aws_subnet.public.*.availability_zone)}"
}
