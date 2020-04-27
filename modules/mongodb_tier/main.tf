
# DB tier

# CREATING NACLs FOR DB
resource "aws_network_acl" "private-nacl" {
  vpc_id = var.vpc_id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.18.0/24"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "90.206.33.13/32"
    from_port  = 22
    to_port    = 22
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "10.0.18.0/24"
    from_port  = 27017
    to_port    = 27017
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.18.0/24"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.18.0/24"
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "${var.name}-private-nacl"
  }
}

# PRIVATE SUBNET
resource "aws_subnet" "mongodb_subnet" {
  vpc_id = var.vpc_id
  cidr_block = "10.0.18.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "${var.name}-private-subnet"
  }
}

# SECURITY GROUPS
resource "aws_security_group" "mongodb_sg" {
  name = "${var.name}-mongodb-sg"
  vpc_id = var.vpc_id
  description = "Security Group that allows port 80 from anywhere."

# INBOUND RULES
  ingress {
    rule_no     = 100
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "90.206.33.13/32"
  }

# OUTBOUND RULES
  egress {
    rule_no     = 100
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-private-sg"
  }
}

# LAUNCHING AN INSTANCE
resource "aws_instance" "mongodb_instance" {
  ami = var.ami_id2
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.mongodb_subnet.id
  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]
  tags = {
    Name = "${var.name}-Mongodb"
  }
  key_name = "camile-eng54"

  user_data = data.template_file.app_init.rendered
}
