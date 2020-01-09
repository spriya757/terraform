

output "datafactory_db_endpoint" {
    value = "${aws_db_instance.datafactory_db.address}"
}
