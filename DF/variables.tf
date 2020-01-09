# networking variables
variable "vpc_cidr"{}

variable "public_cidrs" {}
variable "private_cidrs" {}

#compute variables

variable "accessip" {}
variable "instance_count" {
    default = 1
}

