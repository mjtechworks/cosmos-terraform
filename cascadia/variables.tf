variable "controller_ip" {
  type        = string
  description = "controller_ip"
  default     = "45.126.3.252/32"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cidr" {
    description = "CIDR"
    type        = string
    default = "10.0.0.0/16"
}

variable "nodes" {
    description = "Map of validator names to configuration"
    type = map(object({
        instance_type = string,
        instance_name = string,
        node_type = string,
        storage_type = string,
        storage_size = string,
        private_subnet_cidr_blocks = list(string),
        public_subnet_cidr_blocks = list(string)
    }))

    default = {
        node0 = {
            instance_type           = "t3a.2xlarge",
            instance_name           = "Validator0"
            node_type               = "validator"
            storage_type            = "gp2"
            storage_size            = "1000"
            private_subnet_cidr_blocks  = ["10.0.101.0/24", "10.0.102.0/24"]
            public_subnet_cidr_blocks   = ["10.0.1.0/24", "10.0.2.0/24"]
        },
        node1 = {
            instance_type           = "t3a.2xlarge",
            instance_name           = "Validator1"
            node_type               = "validator"
            storage_type            = "gp2"
            storage_size            = "1000"
            private_subnet_cidr_blocks  = ["10.0.103.0/24", "10.0.104.0/24",]
            public_subnet_cidr_blocks   = ["10.0.3.0/24", "10.0.4.0/24"]
        },
        sentry0 = {
            instance_type           = "t3a.xlarge",
            instance_name           = "Sentry0"
            node_type               = "sentry"
            storage_type            = "gp2"
            storage_size            = "1000"
            private_subnet_cidr_blocks  = ["10.0.105.0/24", "10.0.106.0/24"]
            public_subnet_cidr_blocks   = ["10.0.5.0/24", "10.0.6.0/24"]
        },
        sentry1 = {
            instance_type           = "t3a.xlarge",
            instance_name           = "Sentry1"
            node_type               = "sentry"
            storage_type            = "gp2"
            storage_size            = "500"
            private_subnet_cidr_blocks  = ["10.0.107.0/24", "10.0.108.0/24"]
            public_subnet_cidr_blocks   = ["10.0.7.0/24", "10.0.8.0/24"]
        },
    }
}