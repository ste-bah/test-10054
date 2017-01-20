# AWS Variables
###
# variable "aws_access_key"     { }
# variable "aws_secret_key"     { }
variable "aws_region"         { }
variable "availability_zones" { }
variable "name"	              { }
variable "aws_key_name"       { }
variable "aws_key_path"		  { }

######################################################################
# VPC config settings
###
variable "owner"          { }
variable "email"          { }
variable "group"          { }
variable "env"            { }
variable "account"        { }

######################################################################
# Network config settings
##

# The CIDR notation of the network block to be used.
# e.g.: 10.1.2.0/16, 192.168.1.0/24, etc.
#
# Defaults below assume a /16 sliced into 16 /20s
variable "vpc_cidr"         {}


# Public
# pub_count  = number of public, internet facing subnets to create
# pub_offset = index into a list of possible network blocks which
#              exist in vpc_cidr
#
variable "pub_count"        { }
variable "pub_offset"       { }

# Private
# pri_count  = number of private, non-internet facing subnets to create
# pri_offset = index into a list of possible network blocks which
#              exist in vpc_cidr

variable "pri_count"        { }
variable "pri_offset"       { }
#
# Default is to create 3 private subnets (assumes /20s) begining at the
# bottom of the range.


variable "nat_gateways_count"  { }
