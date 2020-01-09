output "private_subnets" {
    value = "${aws_subnet.datafactory_private_subnet.*.id}"
}

#output "public_subnets" {
 #   value = "${aws_subnet.datafactory_public_subnet.*.id}"
#}

output "vpc" {
    value = "${aws_vpc.datafactory_vpc.id}"
}

