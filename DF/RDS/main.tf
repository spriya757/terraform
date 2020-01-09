resource "aws_security_group" "datafactory_db_sg" {
  name = "datafactory_db_sg"

  description = "RDS postgres servers (terraform-managed)"
  vpc_id = "${var.vpc}"

  # Only postgres in
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}

resource "aws_db_parameter_group" "postgres10_parameter_group" {
  name        = "postgres10-parameter-group"
  family      = "postgresql10"
  description = "postgres10-parameter-group"
}


resource "aws_db_subnet_group" "datafactory_subnet_group" {
  name       = "datafactory_subnet"
  subnet_ids = "${var.subnets}"

  tags = {
    Name = "datafactory subnet group"
  }
}

resource "aws_db_instance" "datafactory_db" {
  allocated_storage        = 32 # gigabytes
  backup_retention_period  = 1   # in days
  db_subnet_group_name     = "${aws_db_subnet_group.datafactory_subnet_group.id}"
  engine                   = "postgres"
  engine_version           = "9.5.15"
  identifier               = "datafactory-db"
  instance_class           = "db.m4.large"
  multi_az                 = false
  name                     = "datafactory"
   
  parameter_group_name     = "${aws_db_parameter_group.postgres10_parameter_group.id}" # if you have tuned it
  password                 = "${trimspace(file("${path.module}/secrets/datafactory-password.txt"))}"
  port                     = 5432
  publicly_accessible      = false
  storage_encrypted        = true # you should always do this
  storage_type             = "gp2"
  username                 = "dbaadmin"
  vpc_security_group_ids   = ["${aws_security_group.datafactory_db_sg.id}"]
}
