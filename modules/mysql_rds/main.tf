resource "aws_security_group" "mysql_rds" {
  name = "${var.env}-${var.rds_instance_name}-mysqlrds-sg"
  description = "Allow all inbound traffic"
  vpc_id = "${var.vpc_id}"

  ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  
          tags {
               "owner" = "${var.owner}"
               "email" = "${var.email}"
               "env"   = "${var.env}"
    }

}


resource "aws_db_instance" "main_rds_instance" {
    identifier = "${var.rds_instance_name}"
    allocated_storage = "${var.rds_allocated_storage}"
    engine = "${var.rds_engine_type}"
    engine_version = "${var.rds_engine_version}"
    allow_major_version_upgrade = true
    skip_final_snapshot = true
    backup_retention_period = 14
    backup_window = "02:00-03:00"
    maintenance_window  = "wed:03:00-wed:04:00"
    instance_class = "${var.rds_instance_class}"
    name = "${var.database_name}"
    username = "${var.database_user}"
    password = "${var.database_password}"
    publicly_accessible = false
    // Because we're assuming a VPC, we use this option, but only one SG id
    vpc_security_group_ids = ["${aws_security_group.mysql_rds.id}"]
    // We're creating a subnet group in the module and passing in the name
    db_subnet_group_name = "${aws_db_subnet_group.main_db_subnet_group.name}"
    parameter_group_name = "${var.db_parameter_group}"
    // We want the multi-az setting to be toggleable, but off by default
    multi_az = "${var.rds_is_multi_az}"
    storage_type = "${var.rds_storage_type}"

          tags {
        Name         = "${var.env}-${rds_instance_name}-DB-Instance-${count.index}"
        VPC          = "${var.vpc_name}"
        ManagedBy    = "terraform"
        env  = "${var.env}"
    }
}

resource "aws_db_subnet_group" "main_db_subnet_group" {
    name = "${var.rds_instance_name}-subnetgrp"
    description = "RDS subnet group"
    subnet_ids = [
        "${split(",", var.private_subnet_ids)}"
    ]
}
