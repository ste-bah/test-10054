//
// Module: tf_aws_rds
//

// RDS Instance Variables

variable "rds_instance_name" {}
variable "rds_is_multi_az" {
    default = "false"
}

variable "rds_storage_type" {
    default = "standard"
}

variable "rds_allocated_storage" {
    description = "The allocated storage in GBs"
    // You just give it the number, e.g. 10
    default = "30"
}
variable "rds_engine_type" {
    // Valid types are
    // - mysql
    // - postgres
    // - oracle-*
    // - sqlserver-*
    // See http://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html
    // --engine
    default = "mysql"
}

variable "rds_engine_version" {
    // For valid engine versions, see:
    // See http://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html
    // --engine-version
    default = "5.6.13"

}

variable "rds_instance_class" {}

variable "database_name" {
    description = "The name of the database to create"
}

variable "database_user" {}
variable "database_password" {}

variable "db_parameter_group" {
    default = "default.mysql5.6"
}

// RDS Subnet Group Variables
variable "private_subnet_ids" {}

// Variables for providers used in this module

variable "owner"          						{ }
variable "email"          						{ }
variable "group"          						{ }
variable "env"            						{ }
variable "account"        						{ }
variable "aws_region"         					{ }
variable "vpc_cidr"         					{ }
variable "vpc_id"           					{ }
variable "vpc_name"           					{ }
variable "availability_zones"					{ }