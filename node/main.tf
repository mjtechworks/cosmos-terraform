resource "aws_security_group" "ssh" {
  description                 = "SG to be applied to validator instance"
  vpc_id                      = var.vpc_id

  ingress {
    from_port                 = 22
    to_port                   = 22
    protocol                  = "tcp"
    cidr_blocks               = [var.controller_ip]
  }
  egress {
    from_port                 = 0
    to_port                   = 0
    protocol                  = "-1"
    cidr_blocks               = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "p2p" {
  description                 = "SG to be applied to validator instance"
  vpc_id                      = var.vpc_id

  ingress {
    from_port                 = 26656
    to_port                   = 26656
    protocol                  = "tcp"
    cidr_blocks               = ["0.0.0.0/0"]
  }
  egress {
    from_port                 = 0
    to_port                   = 0
    protocol                  = "-1"
    cidr_blocks               = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "prometheus" {
  description                 = "SG to be applied to validator instance"
  vpc_id                      = var.vpc_id

  ingress {
    from_port                 = 26660
    to_port                   = 26660
    protocol                  = "tcp"
    cidr_blocks               = ["0.0.0.0/0"]
  }
  egress {
    from_port                 = 0
    to_port                   = 0
    protocol                  = "-1"
    cidr_blocks               = ["0.0.0.0/0"]
  }
}


# aws instance
resource "aws_instance" "node" {
  ami           = var.ubuntu_ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  associate_public_ip_address = true
  # vpc_security_group_ids      = [ 
  #     aws_security_group.ssh.id, 
  #     aws_security_group.p2p.id, 
  #     aws_security_group.prometheus.id 
  # ]

  root_block_device {
    volume_size = var.instance_ebs_storage_size
    volume_type = var.instance_ebs_storage_type
  }

  tags = {
    Name = var.instance_name
  }
}


