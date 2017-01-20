#####################################################
## Empty initialisation variables that will be used by each environments
## TFVARS files and are common to all environments. 
###



variable "vpc_id"								{ }
variable "credentials_file"      				{ }
variable "aws_key_name"          				{ }
variable "aws_key_path"          				{ }
variable "aws_profile"		 					{ }
variable "account_name"          				{ }
variable "environment"           				{ }
variable "vpc_bastion_user"      				{ }
variable "owner"                 				{ }
variable "email"                 				{ }
variable "group"                 				{ }
variable "ssh_user"              				{ }
variable "vpc_cidr"              				{ }
variable "pub_count"            				{ }
variable "pub_offset"            				{ }
variable "pri_count"             				{ }
variable "pri_offset"            				{ }
variable "nat_gateways_count" 	 				{ }
variable "aws_admins"			 				{ }
variable "account_id"		     				{ }


#######################################################################
## initialisation variables for bastion host which is self healing 
###
variable "bastion_name"                      	{ }
variable "bastion_instance_type"             	{ }
variable "bastion_bucket_name"            		{ }
variable "ssh_public_key_names"			     	{ }

#### RDS MYSQL ####						
variable "db_rds_instance_class"				{ }
variable "db_rds_database_user"					{ }
variable "db_rds_database_password"				{ }
variable "db_rds_storage_type"					{ }
variable "db_rds_is_multi_az"					{ }
variable "db_rds_allocated_storage"				{ }
variable "db_rds_engine_type"					{ }
variable "db_rds_engine_version"				{ }
variable "db_rds_database_name"					{ }
variable "db_rds_instance_name"					{ }
variable "db_rds_parameter_group"				{ }