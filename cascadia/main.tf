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

data "aws_availability_zones" "available" {
    state = "available"
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

resource "aws_security_group" "controller" {
  name        = "node"
  description = "Security group for node"

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

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.14.0"

  for_each = var.nodes

  name = "vpc-${each.key}"
  cidr = var.cidr

  azs               =  data.aws_availability_zones.available.names
  private_subnets    = each.value.private_subnet_cidr_blocks
  public_subnets     = each.value.public_subnet_cidr_blocks

  tags = {
    CIDR = var.cidr
  }
}

module "cascadia_nodes" {
  source = "../node/"
  depends_on = [module.vpc]

  for_each = var.nodes

  vpc_id = module.vpc[each.key].vpc_id
  # vpc_security_group_ids = [
  #   aws_security_group.controller.id,
  #   # aws_security_group.node_p2p_port.id,
  #   # aws_security_group.private_validator_port.id,
  #   # aws_security_group.exporter_ports.id
  # ]
  subnet_id  = module.vpc[each.key].public_subnets[0]
  ubuntu_ami = data.aws_ami.ubuntu.id

  key_name = aws_key_pair.node.key_name

  instance_type = each.value.instance_type
  instance_name = each.value.instance_name

  instance_ebs_storage_type = each.value.storage_type
  instance_ebs_storage_size = each.value.storage_size
}