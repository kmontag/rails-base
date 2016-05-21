variable "vpc_id"      { }
variable "vpc_cidr"    { }
variable "region"      { }

variable "db_username" { }
variable "db_password" { }
variable "db_host"     { }

variable "deploy_group_name" {
  description = "The IAM group which should be allowed to SSH into the instances"
}

variable "application_name" {
  description = "The name used by Capistrano when deploying the application"
}

variable "subnet_id" {
  description = "The public-facing subnet where we should launch all resources"
}

variable "username" {
  description = "The username on the instance which deployers will log in as"
  default = "deploy"
}


variable "amis" {
  type        = "map"
  description = "A map of regions -> AMIs for the application"

  # Ubuntu 16.04 hvm:ebs-ssd instances
  default     = {
    us-east-1 = "ami-13be557e"
  }
}

resource "aws_security_group" "application" {
  vpc_id = "${var.vpc_id}"

  # SSH from anywhere
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Web access from within the network
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # All outgoing connections allowed
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_instance_profile" "application" {
  name = "application"
  roles = ["${aws_iam_role.application.name}"]
}

resource "aws_iam_role" "application" {
  name = "application"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "access_public_keys" {
  name = "access_public_keys"
  role = "${aws_iam_role.application.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "iam:ListUsers",
        "iam:GetGroup",
        "iam:ListSSHPublicKeys",
        "iam:GetSSHPublicKey"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "template_file" "init" {
  lifecycle {
    create_before_destroy = true
  }

  template = "${file("${path.module}/init.sh.tpl")}"

  vars = {
    username          = "${var.username}"
    deploy_group_name = "${var.deploy_group_name}"
    db_username       = "${var.db_username}"
    db_password       = "${var.db_password}"
    db_host           = "${var.db_host}"
    application_name  = "${var.application_name}"
  }
}

# Uncomment this and key_name below to debug the IAM-based
# SSH access.
# resource "aws_key_pair" "debug" {
#   key_name = "debug"
#   public_key = "${file("${path.module}/../id_rsa.pub")}"
# }

resource "aws_instance" "application" {
  # key_name = "${aws_key_pair.debug.key_name}"

  lifecycle {
    create_before_destroy = true
  }

  vpc_security_group_ids = ["${aws_security_group.application.id}"]
  subnet_id = "${var.subnet_id}"

  iam_instance_profile = "${aws_iam_instance_profile.application.id}"

  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"

  user_data = "${template_file.init.rendered}"
}

resource "aws_security_group" "elb" {
  vpc_id = "${var.vpc_id}"

  # HTTP from anywhere
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP to the instances
  egress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = [
      "${aws_instance.application.private_ip}/32"
    ]
  }
}

resource "aws_elb" "default" {
  security_groups = ["${aws_security_group.elb.id}"]
  subnets         = ["${var.subnet_id}"]
  instances       = ["${aws_instance.application.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}

output "instance_public_dns" {
  value = "${aws_instance.application.public_dns}"
}

output "elb_dns_name" {
  value = "${aws_elb.default.dns_name}"
}
