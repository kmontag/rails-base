# AWS config
variable "region" {
  description = "AWS region to launch instances"
}

variable "vpc_id" {
  description = "The VPC containing instances"
}

variable "vpc_cidr" {
  description = "The CIDR block of the entire VPC"
}

variable "subnet_id" {
  description = "The public-facing subnet where we should launch all resources"
}

variable "amis" {
  type        = "map"
  description = "A map of regions -> AMIs for the application"

  # Ubuntu 16.04 hvm:ebs-ssd instances
  default     = {
    us-east-1 = "ami-13be557e"
  }
}

# Deploy config
variable "application_name" {
  description = "The name used by Capistrano when deploying the application"
}

variable "deploy_key" {
  description = "Full contents of the deploy key for the application repository"
}

variable "deployers_iam_group_name" {
  description = "The IAM group which should be allowed to SSH into the instances"
}

variable "repo_url" {
  description = "The git repo URL for the application"
}

variable "username" {
  description = "The username on the instance which deployers will log in as"
  default = "deploy"
}

# Application config
variable "bundler_version" {
  description = "The exact bundler version to install on servers"
}

variable "ruby_version" {
  description = "The exact Ruby version to install on servers"
}

variable "npm_version" {
  description = "The exact NPM version to install on servers"
}

# Database info
variable "database_name" { }
variable "database_username" { }
variable "database_password" { }
variable "database_host" { }