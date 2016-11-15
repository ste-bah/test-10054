resource "aws_key_pair" "test" {
  key_name = "${var.aws_key_name}"
  public_key = "${file("../modules/public_keys/test.pub")}"
}