terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

# Create a security group to allow SSH access
resource "aws_security_group" "allow_ssh" {
  name_prefix = "allow-ssh-ansible-"
  description = "Security group for Terraform Ansible integration"

  ingress {
    description = "Allow HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from local machine IP (Zeit)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["149.30.139.86/32"]
  }

  ingress {
    description = "Allow SSH from VSR (WiFi-Access)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.177.160.22/32"]
  }

  ingress {
    description = "Allow SSH from VSR (WiFi-Access-2)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["160.202.58.38/32"]
  }

  egress {
    description = "Allow HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                         = "ami-0945610b37068d87a"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "DTS0428"
  security_groups             = [aws_security_group.allow_ssh.name]
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "TerraAnsible-TEST"
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "${base64encode(file("test_playbook.yml"))}" | base64 -d > /home/ec2-user/test_playbook.yml
    chmod +x /home/ec2-user/test_playbook.yml
    sudo yum update -y
    sudo yum install -y software-properties-common
    sudo yum install -y ansible
    ansible-playbook /home/ec2-user/test_playbook.yml
    EOF
}

// Output the public IP to use with Ansible
output "web_server_ip" {
  value = aws_instance.web.public_ip
}