variable "vpc_id"   { }
variable "vpc_cidr" { }

variable "name" {
  description = "The name of the database to create"
}

variable "username" {
  description = "The username to access the database"
}

variable "password" {
  description = "The password to access the database"
}

variable "subnet_ids" {
  description = <<DESCRIPTION
The comma-separated subnet IDs where we should launch the DB.
DESCRIPTION
  type        = "list"
}
