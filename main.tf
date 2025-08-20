terraform {
  required_version = "~> 1.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
 
# Configure the AWS Provider
provider "aws" {
  region     = "ap-south-1"
   access_key = "key"   # Not recommended for production
  secret_key = "key"
}
resource "aws_instance" "myec2" {
  ami           = "ami-0f918f7e63323f0"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  key_name = "tf-key-pair"
tags = {
    Name = "MYec22"
}
  provisioner "file" {
    source = "myfile.sh"
    destination = "/home/ubuntu/myfile.sh"
    connection {
     type ="ssh"
     user = "ubuntu"
     host = aws_instance.myec2.public_ip
     private_key = tls_private_key.rsa.private_key_pem
  }
}
provisioner "remote-exec" {
    inline = [
     "sudo chmod +x myfile.sh",
     "sudo ./myfile.sh"
     ]
    connection {
     type ="ssh"
     user = "ubuntu"
     host = aws_instance.myec2.public_ip
     private_key = tls_private_key.rsa.private_key_pem
  }
}
}
resource "null_resource" "exec_commands" {
  provisioner "local-exec" {
    command = <<EOT
echo ${aws_instance.myec2.id} >> inst-id.txt
echo ${aws_instance.myec2.private_ip} >> inst-pvt_ip.txt
echo ${aws_instance.myec2.public_ip} >> inst-pub_ip.txt
EOT
  }
 
  triggers = {
    instance_id = aws_instance.myec2.id
  }
}
 
resource "aws_security_group" "mysg" {
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
 
resource "aws_key_pair" "tf-key-pair" {
key_name = "tf-key-pair"
public_key = tls_private_key.rsa.public_key_openssh
}
 
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}
 
resource "local_file" "tf-key" {
content  = tls_private_key.rsa.private_key_pem
filename = "tf-key-pair"
}
