provider "aws" {
  region     = "us-west-1"
}

# Create a security group to allow SSH access
resource "aws_security_group" "allow_ssh" {
  name_prefix = "allow-ssh-ansible-"

  #name = "GroupTerraAnsible"

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
    description = "Allow SSH from local machine IP"
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
    Name = "TerraAnsible"
  }

  provisioner "file" {
    source      = "test_playbook.yml"
    destination = "/home/ec2-user/test_playbook.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/test_playbook.yml",
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("DTS0428.pem")
    host        = self.public_ip
  }
}

// Output the public IP to use with Ansible
output "web_server_ip" {
  value = aws_instance.web.public_ip
}

resource "null_resource" "install_ansible" {
  depends_on = [aws_instance.web]

  provisioner "remote-exec" {
    inline = [
      "sudo yum update",
      "sudo yum install -y software-properties-common",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo yum install -y ansible"
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.web.public_ip
    user        = "ec2-user"
    private_key = file("DTS0428.pem")
  }
}

resource "null_resource" "test-playbook" {
  depends_on = [null_resource.install_ansible]

  provisioner "remote-exec" {
    inline = [
      "ansible-playbook test_playbook.yml"
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.web.public_ip
    user        = "ec2-user"
    private_key = file("DTS0428.pem")
  }
}