##################################################################
## Out put from vpc module 
#
output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}
output "vpc_name" {
  value = "${module.vpc.vpc_name}"
}
output "vpc_cidr" {
  value = "${module.vpc.vpc_cidr}"
}

output "private_subnet_ids" {
  value = "${module.vpc.private_subnet_ids}"
}

output "private_subnet_cidrs" {
  value = "${module.vpc.private_subnet_cidrs}"
}

output "public_subnet_ids" {
  value = "${module.vpc.public_subnet_ids}"
}

output "public_subnet_cidrs" {
  value = "${module.vpc.public_subnet_cidrs}"
}

output "igw_id" {
  value = "${module.vpc.igw_id}"
}

output "nat_eips" {
  value = "${module.vpc.nat_eips}"
}

output "private_route_table_ids" {
  value = "${module.vpc.private_route_table_ids}"
}

output "public_route_table_id" {
  value = "${module.vpc.public_route_table_id}"
}


output "pub_rtbl_assoc_ids" {
   value = "${module.vpc.pub_rtbl_assoc_ids }"
}

output "default_security_group" {
  value = "${module.vpc.default_security_group}"
}

output "availability_zones" {
  value = "${module.vpc.availability_zones}"
}
