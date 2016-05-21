# Sets up a single IAM user with an SSH key in the deployers group.
# The instances are set up to allow SSH access from any IAM user in
# this group based on their public key, so this module can be expanded
# over time to include new team members.

variable "public_key" {
  description = "The public key for the user"
}

resource "aws_iam_group" "deployers" {
  name = "deployers"
}

resource "aws_iam_group_membership" "deployers" {
  name = "deployers-membership"
  users = [
    "${aws_iam_user.admin.name}",
  ]
  group = "${aws_iam_group.deployers.name}"
}

resource "aws_iam_user" "admin" {
  name = "admin"
}

resource "aws_iam_user_ssh_key" "admin" {
  username = "${aws_iam_user.admin.name}"
  encoding = "PEM"
  public_key = "${var.public_key}"
}
