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
  role = "${aws_iam_role.application.name}"
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

# This role allows instances to list the public keys of users in the
# deployers IAM group, which it can use to permit or deny SSH access.
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

# This gets added as user_data to the application instances, meaning
# it runs once on first boot. We use it to e.g. set up SSH access and
# run an initial application deploy.
data "template_file" "init" {
  template = "${file("${path.module}/init.sh.tpl")}"

  vars = {
    username                 = "${var.username}"
    deploy_key               = "${var.deploy_key}"
    deployers_iam_group_name = "${var.deployers_iam_group_name}"
    application_name         = "${var.application_name}"
    repo_url                 = "${var.repo_url}"

    bundler_version          = "${var.bundler_version}"
    npm_version              = "${var.npm_version}"
    ruby_version             = "${var.ruby_version}"

    database_name            = "${var.database_name}"
    database_username        = "${var.database_username}"
    database_password        = "${var.database_password}"
    database_host            = "${var.database_host}"
  }
}

# Uncomment this and key_name below to debug the IAM-based
# SSH access.
# resource "aws_key_pair" "debug" {
#   key_name = "debug"
#   public_key = "${file("${path.root}/id_rsa.pub")}"
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

  # Runs on boot
  user_data = "${data.template_file.init.rendered}"
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
