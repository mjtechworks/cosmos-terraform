terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

locals {
  chain                 = "cascadia"
  chain-id              = "cascadia_9000-1"
  ubuntu_ami            = data.aws_ami.ubuntu.id
}

# Amazon Machine Id (AMI)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.14.0"

  name = "${local.chain}-${local.chain-id}-vpc"
  cidr = "10.1.0.0/16"

  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets     = ["10.1.129.0/24", "10.1.130.0/24", "10.1.131.0/24"]
  private_subnets    = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
#   enable_nat_gateway = true
#   single_nat_gateway = true

  tags = {
    CIDR = "10.1.0.0/16"
  }
}

# aws instance
resource "aws_instance" "validator1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3a.2xlarge"
  key_name      = aws_key_pair.node.key_name
  subnet_id     = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.node.id]

  root_block_device {
    volume_size = 10000
    volume_type = "gp2"
  }

  tags = {
    Name = "Validator1"
  }
}

# ssh key file
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "node" {
  key_name   = "cascadia" # Create a "cascadia" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.node.key_name}.pem"
  content  = tls_private_key.pk.private_key_pem
}

resource "aws_security_group" "node" {
  name        = "node"
  description = "Security group for node"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.controller_ip]
  }

  egress {
    description = "Allow ALL"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sgr
  }

  tags = {
    Name = "node_securitygroup"
  }
}

