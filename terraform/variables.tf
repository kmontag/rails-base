variable "application_name" {
  description = "Name to be used for the VPC and other named resources"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "cidr_block" {
  description = "CIDR block to be used for the entire VPC"
  default     = "10.78.0.0/16"
}

variable "deployers_iam_group_name" {
  description = <<DESCRIPTION
Members of this group will be able to SSH into instances once they
associate their public key with their IAM identity.
DESCRIPTION
  default     = "deployers"
}

variable "repo_url" {
  description = "The git repo URL for the application"
}

# TODO: Vault or some other secure storage
variable "database_name" {
  description = "Name of the database to create"
}

variable "database_username" {
  description = "Username to give access to the database"
}

variable "database_password" {
  description = "Database password"
}