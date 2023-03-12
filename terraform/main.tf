terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    key = "aws/ec2deploy/terraform.tfstate"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#Configure AMI

resource "aws_instance" "webserver" {
  ami                    = "ami-09cd747c78a9add63"
  instance_type          = "tz.micro"
  key_name               = aws_key_pair.deployer
  vpc_security_group_ids = [aws_security_group.mainGroup.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2Profile.name
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = var.private_key
    timeout     = "4m"
  }
  tags = {
    "name" = "DeployVM"
  }
}

resource "aws_iam_instance_profile" "ec2Profile" {
  name = "ec2-peofile"
  role = "EC2-ECR-AUTH"
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.public_key
}

resource "aws_security_group" "mainGroup" {
  egress = [
    {
      cidr_block      = ["0.0.0.0/0"]
      description     = ""
      from_port       = 0
      ipv6_cidr_block = []
      prefix_list_ids = []
      protocol        = "-1"
      security_groups = []
      self            = false
      to_port         = 0
    }
  ]
  ingress = [
    {
      cidr_block      = ["0.0.0.0/0"]
      description     = ""
      from_port       = 22
      ipv6_cidr_block = []
      prefix_list_ids = []
      protocol        = "tcp"
      security_groups = []
      self            = false
      to_port         = 22
    },
    {
      cidr_block      = ["0.0.0.0/0"]
      description     = ""
      from_port       = 80
      ipv6_cidr_block = []
      prefix_list_ids = []
      protocol        = "tcp"
      security_groups = []
      self            = false
      to_port         = 80
    }
  ]
}

# Create a VPC
/* resource "aws_vpc" "mainVpc" {
  cidr_block = "10.0.0.0/16"
} */

output "instance_public_ip" {
  value = aws_instance.webserver
}
