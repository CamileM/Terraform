
# App tier
  # Anything to do with the App gets added in here.

# CREATING NACLs
resource "aws_network_acl" "public-nacl" {
  vpc_id = var.vpc_id
  # subnet_id = [aws_subnet.app_subnet.id]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3000
    to_port    = 3000
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 140
    action     = "allow"
    cidr_block = "90.206.33.13/32"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 150
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 27017
    to_port    = 27017
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.name}-public-nacl"
  }
}

# PUBLIC SUBNET
resource "aws_subnet" "app_subnet" {
  vpc_id = var.vpc_id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "${var.name}-public-subnet"
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

  ingress {
    description = ""
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# DEFAULT OUTBOUND RULES FOR SECURITY GROUP.
  # LETS EVERYTHING OUT
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-public-sg"
  }
}

# ROUTE TABLE
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.gateway_id
  }
  tags = {
    Name = "${var.name}-public"
  }
}

# ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "assoc" {
  subnet_id = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.public.id
}

# TEMPLATE FILE
data "template_file" "app_init" {
  template = file("./scripts/app/init.sh.tpl")
  vars = {
    my_name = "${var.name} is the real name Camile"
    db_private_ip = var.instance_ip_address
  }
}

# LAUNCHING AN INSTANCE
resource "aws_instance" "app_instance" {
  ami = var.ami_id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.app_subnet.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  tags = {
    Name = "${var.name}-App"
  }
  key_name = "camile-eng54"

  user_data = data.template_file.app_init.rendered
}

#   provisioner "remote-exec" {
#     inline = ["cd /home/ubuntu/app", "npm start"]
#   }
#
#   connection {
#     type = "ssh"
#     user = "ubuntu"
#     host = self.public_ip
#     private_key = file("~/.ssh/camile-eng54.pem")
#   }
# }
