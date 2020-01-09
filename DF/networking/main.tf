data "aws_availability_zones" "available"{}
resource "aws_vpc" "datafactory_vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "datafactory_vpc"
    }
}

#resource "aws_internet_gateway" "datafactory_gateway" {
 #   vpc_id = "${aws_vpc.datafactory_vpc.id}"
  #  tags = {
   #     Name = "datafactory_igw"
    #}
#}

#resource "aws_route_table" "datafactory_public_rt" {
 #   vpc_id = "${aws_vpc.datafactory_vpc.id}"
#  route {
 #       cidr_block = "0.0.0.0/0"
  #      gateway_id = "${aws_internet_gateway.datafactory_gateway.id}"
   # }
    #tags = {
     #   Name = "public_rt"
    #}
#}

resource "aws_default_route_table" "datafactory_private_rt" {
    default_route_table_id = "${aws_vpc.bitbucket_vpc.default_route_table_id}"
    tags = {
        Name = "datafactory_private_rt"
    }
}





#resource "aws_subnet" "datafactory_public_subnet" {
 #   vpc_id = "${aws_vpc.datafactory_vpc.id}"
  #  count = 2
   # cidr_block = "${var.public_cidrs[count.index]}"
    #map_public_ip_on_launch = true
    #availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

    #tags = {
     #   Name = "bitbucket_public_${count.index + 1}"
    #}
#}

#resource "aws_route_table_association" "datafactory_public_assoc" {
 #   count = length(aws_subnet.datafactory_public_subnet)
  #  subnet_id = "${aws_subnet.datafactory_public_subnet.*.id[count.index]}"
   # route_table_id = "${aws_route_table.datafactory_public_rt.id}"
#}

resource "aws_subnet" "datafactory_private_subnet" {
    vpc_id = "${aws_vpc.datafactory_vpc.id}"
    count = 2
    cidr_block = "${var.private_cidrs[count.index]}"
    map_public_ip_on_launch = false
    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

    tags = {
        Name = "datafactory_private_${count.index + 1}"
    }
}

resource "aws_route_table_association" "datafactory_private_assoc" {
    count = length(aws_subnet.datafactory_private_subnet)
    subnet_id = "${aws_subnet.datafactory_private_subnet.*.id[count.index]}"
    route_table_id = "${aws_default_route_table.datafactory_private_rt.id}"
}


# create EIP
#resource "aws_eip" "bitbucket_eip" {
 # vpc      = true
  #count = length(aws_subnet.datafactory_private_subnet)
  #depends_on = ["aws_internet_gateway.datafactory_internet_gateway"]
#}

# create NAT gateway
#resource "aws_nat_gateway" "nat" {
 #   count = length(aws_subnet.datafactory_public_subnet)
  #  allocation_id = "${aws_eip.bitbucket_eip.*.id[count.index]}"
   # subnet_id = "${aws_subnet.datafactory_public_subnet.*.id[count.index]}"
    #depends_on = ["aws_internet_gateway.bitbucket_internet_gateway"]
#}


#resource "aws_route_table" "datafactory_private_rt" {
 #   vpc_id = "${aws_vpc.datafactory_vpc.id}"
  #  count = 2
   # route {
    #    cidr_block = "0.0.0.0/0"
     #   gateway_id = "${aws_nat_gateway.nat.*.id[count.index]}"
    #}
    #tags = {
     #   Name = "private_rt_${count.index}"
    #}
#}

#resource "aws_route_table_association" "bitbucket_nat_route_assoc" {
 #   count = length(aws_subnet.datafactory_private_subnet)
  #  subnet_id = "${aws_subnet.datafactory_private_subnet.*.id[count.index]}"
   # route_table_id = "${aws_route_table.datafactory_private_rt.*.id[count.index]}"
#}
