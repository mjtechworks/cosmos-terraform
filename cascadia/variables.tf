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
        cidr = string,
        private_subnet_cidr_blocks = list(string),
        public_subnet_cidr_blocks = list(string)
    }))

    default = {
        validator0 = {
            instance_type           = "t3a.2xlarge",
            instance_name           = "Validator0"
            node_type               = "validator"
            storage_type            = "gp2"
            storage_size            = "1000"
            cidr                    = "10.0.0.0/16"
            private_subnet_cidr_blocks  = ["10.0.101.0/24", "10.0.102.0/24"]
            public_subnet_cidr_blocks   = []
        },
        validator1 = {
            instance_type           = "t3a.2xlarge",
            instance_name           = "Validator1"
            node_type               = "validator"
            storage_type            = "gp2"
            storage_size            = "1000"
            cidr                    = "11.0.0.0/16"
            private_subnet_cidr_blocks  = ["11.0.101.0/24", "11.0.102.0/24"]
            public_subnet_cidr_blocks   = []
        },
        sentry0 = {
            instance_type           = "t3a.xlarge",
            instance_name           = "Sentry0"
            node_type               = "sentry"
            storage_type            = "gp2"
            storage_size            = "1000"
            cidr                    = "101.0.0.0/16"
            private_subnet_cidr_blocks  = ["101.0.101.0/24", "101.0.102.0/24"]
            public_subnet_cidr_blocks   = ["101.0.1.0/24", "101.0.2.0/24"]
        },
        sentry1 = {
            instance_type           = "t3a.xlarge",
            instance_name           = "Sentry1"
            node_type               = "sentry"
            storage_type            = "gp2"
            storage_size            = "500"
            cidr                    = "102.0.0.0/16"
            private_subnet_cidr_blocks  = ["102.0.101.0/24", "102.0.102.0/24"]
            public_subnet_cidr_blocks   = ["102.0.1.0/24", "102.0.2.0/24"]
        },
    }
}