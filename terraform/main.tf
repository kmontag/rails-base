# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  shared_credentials_file = "${path.root}/credentials"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "${var.cidr_block}"

  tags {
    Name = "${var.application_name}"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a group to grant deploy access
resource "aws_iam_group" "deployers" {
  name = "${var.deployers_iam_group_name}"
}

# Create two subnets in different availability zones, to be used for
# our DB subnet group.
resource "aws_subnet" "database" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.default.cidr_block, 8, count.index + 1)}"
  availability_zone = "${var.aws_region}${element(split(",", "a,b"), count.index)}"
  count             = 2
}

# Launch a database
module "database" {
  source = "./database"

  vpc_id = "${aws_vpc.default.id}"
  vpc_cidr = "${aws_vpc.default.cidr_block}"

  name = "${var.database_name}"
  username = "${var.database_username}"
  password = "${var.database_password}"

  subnet_ids = "${aws_subnet.database.*.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "application" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.default.cidr_block, 8, 0)}"
  map_public_ip_on_launch = true
}

# Launch the application
module "application" {
  source = "./application"

  region    = "${var.aws_region}"
  vpc_id    = "${aws_vpc.default.id}"
  vpc_cidr  = "${aws_vpc.default.cidr_block}"
  subnet_id = "${aws_subnet.application.id}"

  bundler_version = "${file("${path.root}/../docker/app/bundler-version")}"
  ruby_version    = "${file("${path.root}/../docker/app/ruby-version")}"
  npm_version     = "${file("${path.root}/../docker/webpack/npm-version")}"

  database_name     = "${var.database_name}"
  database_username = "${var.database_username}"
  database_password = "${var.database_password}"
  database_host     = "${element(split(":", module.database.host), 0)}" # Remove the port number

  # TODO: Store this in vault or somewhere more secure
  deploy_key = "${file("${path.root}/deploy.id_rsa")}"
  repo_url   = "${var.repo_url}"
  deployers_iam_group_name = "${var.deployers_iam_group_name}"
  application_name         = "${var.application_name}"
}
