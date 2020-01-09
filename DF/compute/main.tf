data "aws_availability_zones" "available"{}


resource "aws_security_group" "datafactory_sg"{
    name = "datafactory_sg"
    description = "used for public access"
    vpc_id = "${var.vpc}"

    #SSH access
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.accessip}"]
    }

    ingress {
        from_port = 7999
        to_port = 7999
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        cidr_blocks = ["${var.accessip}"]
    }

    #HTTP access

    ingress {
        from_port = 7990
        to_port = 7990
        protocol = "tcp"
        cidr_blocks = ["${var.accessip}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.accessip}"]

    }

    }


resource "aws_security_group" "bastion_sg"{
    name = "bastion_sg"
    description = "used for public access"
    vpc_id = "${var.vpc}"

    #SSH access
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.accessip}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.accessip}"]

    }

      }
data "template_file" "bitbucket_user_init"{
    #count = 2
    template = "${file("${path.module}/userdata.tpl")}"
    vars = {
        mount-target-dns = "${var.mount-target-dns}"
        bitbucket_db_endpoint = "${var.bitbucket_db_endpoint}"
    }
}

resource "aws_iam_role" "bastion_s3_role" {
  name = "s3_read_role1"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "bastion-s3-read-access"
  }
}

resource "aws_iam_instance_profile" "s3_read_profile" {
  name = "s3_profile1"
  role = "${aws_iam_role.bastion_s3_role.name}"
}

resource "aws_iam_role_policy" "s3_policy" {
  name = "s3_policy1"
  role = "${aws_iam_role.bastion_s3_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_instance" "bastion_host" {
    count = 2
    instance_type = "t2.large"
    #ami = "ami-0d8f6eb4f641ef691"
    ami = "ami-0b69ea66ff7391e80"
    tags = {
        Name = "bastion_server_${count.index}"
    }
    key_name = "bitbucket_key"
    subnet_id = "${var.public_subnets[count.index]}"
    vpc_security_group_ids = ["${aws_security_group.bastion_sg.id}"]
    iam_instance_profile = "${aws_iam_instance_profile.s3_read_profile.name}"
}
