provider "aws" {
  region = var.aws_region
}

# -----------------
# VPC (use default)
# -----------------
data "aws_vpc" "default" {
  default = true
}

# -----------------
# Subnets
# -----------------
resource "aws_subnet" "public_ec2" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.public_subnet_az
  map_public_ip_on_launch = true
  tags                    = { Name = "public-subnet-ec2" }
}

resource "aws_subnet" "db_subnet1" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = var.db_subnet1_cidr
  availability_zone       = var.db_subnet1_az
  map_public_ip_on_launch = false
  tags                    = { Name = "db-subnet-1" }
}

resource "aws_subnet" "db_subnet2" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = var.db_subnet2_cidr
  availability_zone       = var.db_subnet2_az
  map_public_ip_on_launch = false
  tags                    = { Name = "db-subnet-2" }
}

# -----------------
# Security Groups
# -----------------
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg-tf"
  description = "EC2 SG: SSH + HTTP inbound; all outbound"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ec2-sg-tf" }
}

resource "aws_security_group" "db_sg" {
  name        = "db-sg-tf"
  description = "DB SG: MySQL inbound from EC2 SG; all outbound"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "MySQL from EC2 SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "db-sg-tf" }
}

# -----------------
# EC2 Instance
# -----------------
resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_ec2.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo dnf install -y https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rm
              sudo dnf install -y mysql-community-client --nogpgcheck
              EOF

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = { Name = "ec2-with-extra-volume" }
}

# Extra 20GB volume + snapshot
resource "aws_ebs_volume" "extra20" {
  availability_zone = aws_instance.web.availability_zone
  size              = 20
  type              = "gp3"
  tags              = { Name = "extra-20gb" }
}

resource "aws_volume_attachment" "extra20_attach" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.extra20.id
  instance_id = aws_instance.web.id
}

resource "aws_ebs_snapshot" "extra20_backup" {
  volume_id = aws_ebs_volume.extra20.id
  tags = {
    Name      = "extra-20gb-initial-backup"
    CreatedBy = "terraform"
  }
  depends_on = [aws_volume_attachment.extra20_attach]
}

# -----------------
# RDS MySQL
# -----------------
resource "aws_db_subnet_group" "default" {
  name       = "tf-rds-subnet-group"
  subnet_ids = [aws_subnet.db_subnet1.id, aws_subnet.db_subnet2.id]
  tags       = { Name = "tf-rds-subnet-group" }
}

resource "aws_db_instance" "mysql" {
  identifier             = "my-mysql-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  storage_type           = "gp2"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  apply_immediately      = true
  deletion_protection    = false

  tags = { Name = "mysql-rds" }
}

# -----------------
# Outputs
# -----------------
output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.address
}

