
# Configuration in AWS

provider "aws" {
  region = "eu-west-1"
}

# Creating a VPC

#resource "aws_vpc" "app_vpc" {
#  cidr_block = "10.0.0.0/16"
#  tags = {
#    Name = "ENG-54-app_vpc"
#  }
# }


# Use our DevOps VPC
  # vpc-07e47e9d90d2076da
# Create a new Subnet
# Move our instance into the Subnet

resource "aws_subnet" "app_subnet" {
  vpc_id = var.vpc_id
  cidr_block = "172.31.15.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = var.name
  }
}

# EXAMPLE 2 FOR SECURITY GROUPS
resource "aws_security_group" "app_security_group" {
  name = "app-sg-Camile-name"
  vpc_id = var.vpc_id
  description = "Security Group that allows port 80 from anywhere."

# INBOUND RULES
  ingress {
    description = "Allows Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# DEFAULT OUTBOUND RULES FOR SECURITY GROUP.
   # LETS EVERYTHING OUT
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-tags"
  }
}

# Launching an Instance
resource "aws_instance" "app_instance" {
  ami = var.ami_id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.app_subnet.id
  vpc_security_group_ids = [aws_security_group.app_security_group.id]

  tags = {
    Name = "${var.name}-tags"
  }
}
