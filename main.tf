
# Configuration in AWS

provider "aws" {
  region = "eu-west-1"
}

# Creating a VPC
  # resource "aws_vpc" "app_vpc" {
  #  cidr_block = "10.0.0.0/16"
  #  tags = {
  #    Name = "ENG-54-app_vpc"
  #  }
  # }

# Use our DevOps VPC : vpc-07e47e9d90d2076da
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

# ROUTE TABLE
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.default-gw.id
  }
  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table_association" "assoc" {
  subnet_id = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.public.id
}

# INTERNET GATEWAY
data "aws_internet_gateway" "default-gw" {
  filter {
      # ON THE HASHICORP DOCS
    name = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

# SECURITY GROUPS
resource "aws_security_group" "app_sg" {
  name = "${var.name}-sg"
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

  ingress {
    description = "Allows Port 3000"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allows Port 22"
    from_port   = 22
    to_port     = 22
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
    Name = "sg-${var.name}-tags"
  }
}

# Launching an Instance
resource "aws_instance" "app_instance" {
  ami = var.ami_id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.app_subnet.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  tags = {
    Name = "${var.name}"
  }
  key_name = "camile-eng54"

  provisioner "remote-exec" {
    inline = ["cd /home/ubuntu/app", "npm start"]
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    host = self.public_ip
    private_key = file("~/.ssh/camile-eng54.pem")
  }
}
