provider "aws" {
  region = var.aws_region
}
locals{
  ### This assigns the IP Block of 10.64.0.0 to 10.95.255.255 to this specific subnet.
  ### It then splits this block up into 8 equal sized chunks along subnet boundries for assignment to different regions
  ### The cidrsubnet commands can be typed directly into terraform console to see what they render
  ### The first region, us-east-1 has a subnet of 10.64.0.0/14.  Region8 has a subnet of 10.92.0.0/14.
  ### These subnets support over 250k hosts per VPC.

  testnet_1_cidr = "10.64.0.0/13"
  testnet_1_cidrs_by_region = {
    us-east-1 = cidrsubnet(local.testnet_1_cidr, 3 ,0)
    region2 = cidrsubnet(local.testnet_1_cidr, 3 ,1)
    region3 = cidrsubnet(local.testnet_1_cidr, 3 ,2)
    # ...
    region8 = cidrsubnet(local.testnet_1_cidr, 3 ,7) # Last one
  }
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

  name = "cascadia-testnet-1-vpc-${local.region}"
  cidr = local.testnet_1_cidrs_by_region[local.region]

  azs               =  data.aws_availability_zones.available.names
  ### Split our VPC into 4 subnets and take the first 2 elements of the list as private subnets.
  private_subnets    = slice( cidrsubnets(local.testnet_1_cidrs_by_region[local.region], 2, 2, 2, 2), 0, 2)
  ### Split our VPC into 4 subnets and take everything from the 3rd to the 4th elements in the list
  public_subnets     = slice( cidrsubnets("10.64.0.0/16", 2, 2, 2, 2), 2, 4)
  default_vpc_enable_dns_hostnames = true
  enable_nat_gateway = true

  tags = {
    CIDR = local.testnet_1_cidrs_by_region[local.region]
  }
}

module "cascadia_nodes" {
  source = "../node/"
  depends_on = [module.vpc]

  for_each = var.nodes

  vpc_id = module.vpc.vpc_id

  subnet_id  = each.value.node_type == "sentry" ?  element(module.vpc.public_subnets, each.value.index % length(module.vpc.public_subnets) ) : element(module.vpc.private_subnets, each.value.index% length(module.vpc.public_subnets))
  security_groups = each.value.node_type == "sentry" ? [aws_security_group.https_ingress.id] : [aws_security_group.ssh.id]
  ubuntu_ami = data.aws_ami.ubuntu.id

  key_name = aws_key_pair.node.key_name

  instance_type = each.value.instance_type
  instance_name = each.value.instance_name

  instance_ebs_storage_type = each.value.storage_type
  instance_ebs_storage_size = each.value.storage_size
}

