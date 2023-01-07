# aws instance
resource "aws_instance" "node" {
  ami           = var.ubuntu_ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  # vpc_security_group_ids = var.vpc_security_group_ids

  root_block_device {
    volume_size = var.instance_ebs_storage_size
    volume_type = var.instance_ebs_storage_type
  }

  tags = {
    Name = var.instance_name
  }
}


