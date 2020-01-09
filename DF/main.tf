provider "aws" {
    region = "us-east-1"

}

# Deploy networking  resources
module "networking" {
    source = "./networking"
    vpc_cidr = "${var.vpc_cidr}"
    #public_cidrs = "${var.public_cidrs}"
    private_cidrs = "${var.private_cidrs}"
}

#module "RDS" 
module "RDS" {
    source = "./RDS"
    subnets = "${module.networking.private_subnets}"
    vpc = "${module.networking.vpc}"
    #private_cidrs = "${var.private_cidrs}"

}







