variable "name" {
  default = "bastion"
}

variable "env"            { }
variable "owner"          { }
variable "email"          { }
variable "group"          { }
variable "account"        { }
variable "ami"            { }
variable "account_id"     { }
variable "aws_admins"     { }
variable "aws_key_path"     { }
variable "policy_var1"             { 
  default = ""
}  
variable "policy_var2"             { 
  default = ""

}

variable "aws_key_name" { }

variable "ssh_public_key_names" {
  default = "user1,user2,admin"
}

variable "bastion_instance_type" { 
  default = "t2-micro"
}

variable "user_data_file" {
  default = "user_data.sh"
}
variable "bastion_bucket_name" { }
variable "s3_bucket_uri" {
  default = ""
}
variable "ssh_user" {
  default = "ubuntu"
}
variable "enable_hourly_cron_updates" {
  default = "true"
}
variable "keys_update_frequency" {
  default = ""
}
variable "additional_user_data_script" {
  default = ""
}
variable "region" {
  default = "eu-west-1"
}
variable "vpc_id" {
}
variable "security_group_ids" {
  description = "Comma seperated list of security groups to apply to the bastion."
  default = ""
}
variable "subnet_ids" { }
variable "eip" {
  default = ""
}