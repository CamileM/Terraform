
# Configuration in AWS

provider "aws" {
  region = "eu-west-1"
}

# Creating a VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
     Name = "${var.name}-vpc"
   }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.name}-igw"
  }
}

# data "aws_internet_gateway" "default-gw" {
#   filter {
#       # ON THE HASHICORP DOCS
#     name = "attachment.vpc-id"
#     values = [var.vpc_id]
#   }
# }

# Creates App with the variables we passed to it
module "app" {
  source = "./modules/app_tier"
  vpc_id = aws_vpc.app_vpc.id
  name = var.name
  ami_id = var.ami_id
  gateway_id = aws_internet_gateway.igw.id
}

module "db" {
  source = "./modules/app_tier"
  vpc_id = aws_vpc.app_vpc.id
  name = var.name
  ami_id = var.ami_id
  gateway_id = aws_internet_gateway.igw.id
}
