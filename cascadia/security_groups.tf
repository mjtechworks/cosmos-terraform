resource "aws_security_group" "ssh" {
  description                 = "SG to be applied to validator instance"
  vpc_id                      = module.vpc.vpc_id

  ingress {
    from_port                 = 22
    to_port                   = 22
    protocol                  = "tcp"
    cidr_blocks               = var.controller_ips
  }
  egress {
    from_port                 = 0
    to_port                   = 0
    protocol                  = "-1"
    cidr_blocks               = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "https_ingress" {
  description                 = "SG to be applied to sentry instance"
  vpc_id                      = module.vpc.vpc_id

  ingress {
    from_port                 = 22
    to_port                   = 22
    protocol                  = "tcp"
    cidr_blocks               = var.controller_ips
  }
    ingress {
    from_port                 = 443
    to_port                   = 443
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