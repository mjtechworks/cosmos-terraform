provider "aws" {
  region = var.aws_region
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

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.14.0"

  for_each = var.nodes

  name = "vpc-${each.key}"
  cidr = each.value.cidr

  azs               =  data.aws_availability_zones.available.names
  private_subnets    = each.value.private_subnet_cidr_blocks
  public_subnets     = each.value.public_subnet_cidr_blocks
  default_vpc_enable_dns_hostnames = true

  tags = {
    CIDR = each.value.cidr
  }
}

module "cascadia_nodes" {
  source = "../node/"
  depends_on = [module.vpc]

  for_each = var.nodes

  vpc_id = module.vpc[each.key].vpc_id

  subnet_id  = module.vpc[each.key].private_subnets[0]
  ubuntu_ami = data.aws_ami.ubuntu.id

  key_name = aws_key_pair.node.key_name

  instance_type = each.value.instance_type
  instance_name = each.value.instance_name

  instance_ebs_storage_type = each.value.storage_type
  instance_ebs_storage_size = each.value.storage_size
}

locals {
  peerings = distinct(flatten([
    for i, requester in keys(var.nodes) : [
      for j, accepter in keys(var.nodes) : {
          requester = requester
          accepter = accepter
      } if i < j
    ]
  ]))
}

module "vpc_peering" {
  source = "cloudposse/vpc-peering/aws"
  for_each = { for index, peering in local.peerings : index => peering if var.nodes[peering.requester].node_type == "sentry" || var.nodes[peering.accepter].node_type == "sentry"}

  namespace        = "eg"
  stage            = "dev"
  name             = "cluster"
  requestor_vpc_id = module.vpc[each.value.requester].vpc_id
  acceptor_vpc_id  = module.vpc[each.value.accepter].vpc_id
  requestor_allow_remote_vpc_dns_resolution  = false
  acceptor_allow_remote_vpc_dns_resolution  = false
}
