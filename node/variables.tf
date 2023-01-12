variable "controller_ip" {
  type        = string
  description = "controller_ip"
  default     = "45.126.3.252/32"
}

variable "ubuntu_ami" {
  description = "ubuntu_ami"
  type        = string
}

variable "subnet_id" {
  description = "public_subnet_id"
  type        = string
}

variable "vpc_id" {
  description = "Name to be used on the Default VPC"
  type        = string
}

variable "instance_ebs_storage_size" {
  type        = number
  description = "The application instance EBS storage size for the EBS block device"
}

variable "instance_ebs_storage_type" {
  type        = string
  description = "The application instance EBS storage type for the EBS block device"
  default     = "standard"
}

variable "instance_name" {
  type        = string
  description = "The EC2 instance name used for the application"
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type used for the application"
}

variable "key_name" {
  type        = string
  description = "key_name"
}

variable "security_groups" {
  type        = list(string)
  description = "The security groups this node should be placed in."
}

# variable "vpc_security_group_ids" {
#   description = "vpc_security_group_ids"
#   type        = list(any)
#   default     = []
# }