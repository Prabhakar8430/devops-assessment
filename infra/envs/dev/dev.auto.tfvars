aws_region = "ap-south-1"

environment = "dev"

vpc_cidr = "10.0.0.0/16"

public_subnets = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnets = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

db_instance_class = "db.t3.micro"

backup_retention_period = 1

deletion_protection = false

db_name = "hoteldb"

db_username = "postgres"

db_password = "Password@123"