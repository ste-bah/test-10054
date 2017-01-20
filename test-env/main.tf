provider "aws" {
    profile                                 = "${var.aws_profile}"
    region                                  = "${var.aws_region}"
    shared_credentials_file                 = "${var.credentials_file}"
  #   assume_role {
  #   role_arn     = "arn:aws:iam::000000000000:role/terraform"
  # }
}

module "vpc" {
    source                                      = "../modules/aws_vpc"
    env                                     = "${var.environment}"
    # aws_access_key                          = "${var.aws_access_key}"
    # aws_secret_key                          = "${var.aws_secret_key}"
    aws_key_name                            = "${var.aws_key_name}"
    aws_key_path                            = "${var.aws_key_path}"
    aws_region                              = "${var.aws_region}"
    name                                    = "${var.environment}"
    account                                 = "${var.account_name}"
    availability_zones                      = "${var.availability_zones}"
    group                                     = "${var.group}"
    owner                                     = "${var.owner}"
    vpc_cidr                                = "${var.vpc_cidr}"
    email                                     = "${var.email}"
    nat_gateways_count                      = "${var.nat_gateways_count}"
    pub_count                               = "${var.pub_count}"
    pub_offset                              = "${var.pub_offset}"
    pri_count                               = "${var.pri_count}"
    pri_offset                              = "${var.pri_offset}"
}

module "bastion_ami" {
  source                                                = "github.com/terraform-community-modules/tf_aws_ubuntu_ami/ebs"
  instance_type                                         = "t2.micro"
  region                                                = "${var.aws_region}"
  distribution                                          = "xenial"
  architecture                                          = "amd64"
  storagetype                                           = "ebs-ssd"
}

module "bastion" {
    source             						= "../modules/bastion"
    aws_admins         						= "admin"
    policy_var1       						= "admin"
    policy_var2        						= "${var.bastion_bucket_name}"
    aws_key_name       						= "${var.aws_key_name}"
    account_id         						= "${var.account_id}"
    region             						= "${var.aws_region}"
    env                						= "${var.environment}"
    name               						= "${var.bastion_name}"
    group              						= "${var.group}"
    account            						= "${var.account_name}"
    owner              						= "${var.owner}"
    email              						= "${var.email}"
    aws_key_path       						= "${var.aws_key_path}"
    bastion_instance_type 					= "${var.bastion_instance_type}"
    ami                						= "${module.bastion_ami.ami_id}"
    region             						= "${var.aws_region}"
    bastion_bucket_name     				= "${var.bastion_bucket_name}"
    vpc_id             						= "${module.vpc.vpc_id}"
    ssh_public_key_names 					= "${var.ssh_public_key_names}"
    subnet_ids         						= "${module.vpc.public_subnet_ids}"
    keys_update_frequency 					= "5,20,35,50 * * * *"
    additional_user_data_script 			= ""

}

module "mysql_rds" {
   source                                  = "../modules/mysql_rds"
   vpc_cidr                                = "${var.vpc_cidr}"
   vpc_id                                  = "${module.vpc.vpc_id}"
   vpc_name                                = "${module.vpc.vpc_name}"
   env                                     = "${var.environment}"
   aws_region                              = "${var.aws_region}"
   account                                 = "${var.account_name}"
   group                                   = "${var.group}"
   owner                                   = "${var.owner}"
   email                                   = "${var.email}"
   private_subnet_ids                      = "${module.vpc.private_subnet_ids}"
   availability_zones                      = "${var.availability_zones}"
   rds_instance_class                      = "${var.db_rds_instance_class}"
   database_user                           = "${var.db_rds_database_user}"
   database_password                       = "${var.db_rds_database_password}"
   rds_storage_type                        = "${var.db_rds_storage_type}"
   rds_is_multi_az                         = "${var.db_rds_is_multi_az}"
   rds_allocated_storage                   = "${var.db_rds_allocated_storage}"
   rds_engine_type                         = "${var.db_rds_engine_type}"
   rds_engine_version                      = "${var.db_rds_engine_version}"
   database_name                           = "${var.db_rds_database_name}"
   rds_instance_name                       = "${var.db_rds_instance_name}"
   db_parameter_group                      = "${var.db_rds_parameter_group}"

}




