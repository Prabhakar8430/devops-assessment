variable "aws_region" {}

variable "environment" {}

variable "vpc_cidr" {}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "db_instance_class" {}

variable "backup_retention_period" {
  type = number
}

variable "deletion_protection" {
  type = bool
}

variable "db_name" {}

variable "db_username" {}

variable "db_password" {
  sensitive = true
}