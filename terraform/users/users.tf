# Sets up a single IAM user with an SSH key. The instances are
# set up to allow SSH access from any IAM user based on their
# public key, so this module can be expanded over time to
# include new team members.

variable "public_key" {
  description = "The public key for the user"
}

resource "aws_iam_user" "deployer" {
  name = "deployer"
  path = "/"
}

resource "aws_iam_user_ssh_key" "deployer" {
  username = "${aws_iam_user.deployer.name}"
  encoding = "PEM"
  public_key = "${var.public_key}"
}
