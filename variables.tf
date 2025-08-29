variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI for EC2"
  type        = string
  default     = "ami-00ca32bbc84273381" # Amazon Linux 2 us-east-1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "my-linux-webserver"
}

variable "public_subnet_cidr" {
  description = "CIDR for public EC2 subnet"
  type        = string
  default     = "172.31.30.0/24"
}

variable "public_subnet_az" {
  description = "AZ for public subnet"
  type        = string
  default     = "us-east-1a"
}

variable "db_subnet1_cidr" {
  description = "CIDR for DB subnet 1"
  type        = string
  default     = "172.31.10.0/24"
}

variable "db_subnet1_az" {
  description = "AZ for DB subnet 1"
  type        = string
  default     = "us-east-1a"
}

variable "db_subnet2_cidr" {
  description = "CIDR for DB subnet 2"
  type        = string
  default     = "172.31.20.0/24"
}

variable "db_subnet2_az" {
  description = "AZ for DB subnet 2"
  type        = string
  default     = "us-east-1b"
}

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "DB admin username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "DB admin password"
  type        = string
  default     = "Rocky659803!"
  sensitive   = true
}

