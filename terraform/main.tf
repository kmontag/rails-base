variable "access_key" {
  description = "Your AWS access key"
}

variable "secret_key" {
  description = "Your AWS secret key"
}

variable "public_key" {
  description = "Your PEM public key for SSH access to the application"
}

variable "name" {
  description = "The name of the application"
  default     = "rails_base"
}

variable "cidr" {
  description = "The CIDR block for the entire VPC"
  default     = "10.66.0.0/16"
}

variable "region" {
  description = "The AWS region to launch resources"
  default     = "us-east-1" # Currently ACM is only supported in us-east-1
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# The VPC containing all other resources
module "vpc" {
  source = "github.com/hashicorp/best-practices//terraform/modules/aws/network/vpc"
  name   = "${var.name}"
  cidr   = "${var.cidr}"
}

# Two public-facing subnets, one for web- and SSH-accessible resources, and one for
# internal resources. In a real-world application we'd have the internal resources on
# a private subnet, but that would require a NAT gateway, which would take us out of
# the free tier.
module "public_subnets" {
  source = "github.com/hashicorp/best-practices//terraform/modules/aws/network/public_subnet"
  vpc_id = "${module.vpc.vpc_id}"
  cidrs  = "${cidrsubnet(var.cidr, 8, 2)},${cidrsubnet(var.cidr, 8, 3)}"
  azs    = "${var.region}a,${var.region}b"
}

module "db" {
  source     = "./db"

  vpc_id     = "${module.vpc.vpc_id}"
  vpc_cidr   = "${module.vpc.vpc_cidr}"

  name       = "${var.name}_production"
  username   = "${var.name}"

  # DB subnet groups need at least two subnets
  subnet_ids = "${module.public_subnets.subnet_ids}"
}

module "application" {
  source    = "./application"
  region    = "${var.region}"
  vpc_id    = "${module.vpc.vpc_id}"
  vpc_cidr  = "${module.vpc.vpc_cidr}"
  subnet_id = "${element(split(",", module.public_subnets.subnet_ids), 0)}"
}

module "users" {
  source = "./users"
  public_key = "${var.public_key}"
}

output "ssh_host" {
  value = "${module.application.instance_public_dns}"
}

output "web_host" {
  value = "${module.application.elb_dns_name}"
}
