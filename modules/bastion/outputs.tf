###########################################
## bastion Server Outputs
###

output "bastion_elb_sg_id" {
    value = "${aws_security_group.bastion_elb.id}"
}

output "bastion_server_sg_id" {
    value = "${aws_security_group.bastion.id}"
}

output "bastion_elb_dns_name" {
    value = "${aws_elb.bastion.dns_name}"
}

output "iam_role_policy_arn_bastion" {
    value = "${aws_iam_role_policy.s3_readonly_policy.arn}"
}

output "iam_instance_profile_name_bastion" {
    value = "${aws_iam_instance_profile.s3_readonly.name}"
}

output "bastion_ssh_user" {
  value = "${var.ssh_user}"
}

output "bastion_security_group_id" {
  value = "${aws_security_group.bastion.id}"
}
