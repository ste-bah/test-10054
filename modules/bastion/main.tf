###############################################################################
## Create iam role, instance profile and read only s3 policy for the bastion
## s3 bucket where the keys will be stored.
###

resource "aws_iam_role_policy" "s3_readonly_policy" {
  name   = "${var.env}-s3-readonly-policy"
  role   = "${aws_iam_role.s3_readonly.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:List*",
                "s3:Get*"
            ],
            "Resource":[
                "arn:aws:s3:::${var.policy_var2}",
                "arn:aws:s3:::${var.policy_var2}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "s3_readonly" {
  name  = "${var.env}-s3-readonly"
  roles = ["${aws_iam_role.s3_readonly.name}"]
}

resource "aws_iam_role" "s3_readonly" {
  name               = "${var.env}-s3-readonly-role"
  path               = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

###############################################################################
## Put pre-generated ssh public keys in to the s3 bucket ready for the bastion
## host. Terraform manages the transfer to the bucket not the bastion.
###

resource "aws_s3_bucket" "ssh_public_keys" {
  region = "${var.region}"
  bucket = "${var.bastion_bucket_name}"
  acl    = "private"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {"AWS": "${var.account_id}"},
            "Action": ["s3:List*","s3:Get*"],
            "Resource":["arn:aws:s3:::${var.policy_var2}","arn:aws:s3:::${var.policy_var2}/*"]
        }
    ]
}
EOF
}

resource "aws_s3_bucket_object" "ssh_public_keys" {
  bucket     = "${aws_s3_bucket.ssh_public_keys.bucket}"
  key        = "${element(split(",", var.ssh_public_key_names), count.index)}.pub"

  # Make sure that you put files into correct location and name them accordingly (`public_keys/{keyname}.pub`)
  content    = "${file("../modules/public_keys/${element(split(",", var.ssh_public_key_names), count.index)}.pub")}"
  count      = "${length(split(",", var.ssh_public_key_names))}"

  depends_on = ["aws_s3_bucket.ssh_public_keys"]
}


##############################################################################
#
##

resource "aws_security_group" "bastion" {
  name_prefix       = "${var.env}_${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "Bastion security group (only SSH inbound access is allowed)"

  tags {
    Name = "${var.env}.${var.name}"
    "owner" = "${var.owner}"
    "email" = "${var.email}"
    "role" = "bastion"
    "env"   = "${var.env}"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    security_groups = ["${aws_security_group.bastion_elb.id}"]
  }

    ingress {
    protocol    = "udp"
    from_port   = 123
    to_port     = 123
   security_groups = ["${aws_security_group.bastion_elb.id}"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
      tags {
               "owner" = "${var.owner}"
               "email" = "${var.email}"
               "group" = "bastion"
               "env"   = "${var.env}"
    }
        lifecycle {
    create_before_destroy = true
    ignore_changes = [
      "ingress"
    ]
  }
}
############################################################################

#

data "template_file" "user_data" {
  template = "${file("${path.module}/scripts/${var.user_data_file}")}"

  vars {
    s3_bucket_name              = "${var.bastion_bucket_name}"
    s3_bucket_uri               = "${var.s3_bucket_uri}"
    ssh_user                    = "${var.ssh_user}"
    keys_update_frequency       = "${var.keys_update_frequency}"
    enable_hourly_cron_updates  = "${var.enable_hourly_cron_updates}"
    additional_user_data_script = "${var.additional_user_data_script}"
  }

}
###################################################################################
#Setup Bastion ELB Security Group
#

resource "aws_security_group" "bastion_elb" {
    name_prefix = "${var.env}_bastion_elb_sg"
    vpc_id = "${var.vpc_id}"
    description = "bastion external  traffic "

    // This is for incoming traffic
    ingress {
        from_port = 2222
        to_port = 2222
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
 
    // This is for outbound internet access
    egress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
               "owner" = "${var.owner}"
               "email" = "${var.email}"
               "group" = "bastion"
               "env"   = "${var.env}"
    }
    lifecycle {
    create_before_destroy = true
    ignore_changes = [
      "ingress"
    ]
  }
}

####################################################################################
## Setup elb for bastion hosts 
###


resource "aws_elb" "bastion" {
  subnets = ["${split(",", var.subnet_ids)}"]
  internal = "false"
  cross_zone_load_balancing = "true"
  connection_draining = "true"
  connection_draining_timeout = "30"
  idle_timeout = "600"
  security_groups = ["${aws_security_group.bastion_elb.id}"]

  
  listener {
    instance_port = 22
    instance_protocol = "tcp"
    lb_port = 2222
    lb_protocol = "tcp"
  }


   health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 10
    target = "tcp:22"
    interval = 60
  }

   tags {
               "Name" = "${var.env}-bastion-elb"
               "owner" = "${var.owner}"
               "email" = "${var.email}"
               "role" = "bastion"
               "env"   = "${var.env}"
   }

    lifecycle {
    create_before_destroy = true
  }
}


###################################################################################
# Setup route53 service CNAME  DNS record for the elb & an internal domain alias
##

# resource "aws_route53_record" "bastion" {
#    zone_id = "${var.route53primary_zone_id}"
#    name = "${var.env}_elb_bastion"
#    type = "CNAME"
#    ttl = "60"
#    records = ["${aws_elb.bastion.dns_name}"]
#      lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_route53_record" "bastion_int" {
#   zone_id = "${var.vpc_private_dns_record}"
#   name    = "aws_${var.env}-elb_bastion"
#   type    = "A"
#   alias {
#     name = "${aws_elb.bastion.dns_name}"
#     zone_id = "${aws_elb.bastion.zone_id}"
#     evaluate_target_health = true
#   }
#     lifecycle {
#     create_before_destroy = true
#   }
 
# }

###################################################################################
# Create launch configuration for the bastion hosts
##

resource "aws_launch_configuration" "bastion" {
  name_prefix          = "${var.name}-"
  image_id             = "${var.ami}"
  instance_type        = "${var.bastion_instance_type}"
  user_data            = "${data.template_file.user_data.rendered}"
  user_data = ""
  security_groups      = ["${aws_security_group.bastion.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.s3_readonly.name}"
  key_name = "${var.aws_key_name}"
  associate_public_ip_address = true
 
     lifecycle {
    create_before_destroy = true
  }

}


####################################################################################
## Create autoscaling group for the bastion hosts
###

resource "aws_autoscaling_group" "bastion" {
  vpc_zone_identifier       = [
    "${split(",", var.subnet_ids)}"
  ]
  load_balancers = ["${aws_elb.bastion.name}"]
  desired_capacity          = "1"
  min_size                  = "1"
  max_size                  = "2"
  health_check_grace_period = "60"
  health_check_type         = "EC2"
  force_delete              = false
  wait_for_capacity_timeout = 0
  launch_configuration      = "${aws_launch_configuration.bastion.name}"
 
  tag {
     key = "Name"
     value = "${var.env}-bastion-server"
     propagate_at_launch = true
   }
     tag {
     key = "env"
     value = "${var.env}"
     propagate_at_launch = true
   }

    lifecycle {
    create_before_destroy = true
  }

}

