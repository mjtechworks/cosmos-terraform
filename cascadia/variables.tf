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
        index = number,
    }))

    default = {
        validator0 = {
            instance_type           = "t3a.2xlarge",
            instance_name           = "Validator0"
            node_type               = "validator"
            storage_type            = "gp2"
            storage_size            = "1000"
            cidr                    = "10.0.0.0/16"
            index                   = 0
        },
        validator1 = {
            instance_type           = "t3a.2xlarge",
            instance_name           = "Validator1"
            node_type               = "validator"
            storage_type            = "gp2"
            storage_size            = "1000"
            cidr                    = "11.0.0.0/16"
            index                   = 1
        },
        sentry0 = {
            instance_type           = "t3a.xlarge",
            instance_name           = "Sentry0"
            node_type               = "sentry"
            storage_type            = "gp2"
            storage_size            = "1000"
            cidr                    = "101.0.0.0/16"
            index                       = 0
        },
        sentry1 = {
            instance_type           = "t3a.xlarge",
            instance_name           = "Sentry1"
            node_type               = "sentry"
            storage_type            = "gp2"
            storage_size            = "500"
            cidr                    = "102.0.0.0/16"
            index = 1
        },
    }
}

variable "controller_ips" {
  type        = list
  description = "controller_ip"
  default     = ["45.126.3.252/32"]
}