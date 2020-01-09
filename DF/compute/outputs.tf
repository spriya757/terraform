#output "instance" {
 #   value = "${aws_instance.bitbucket_instance.id}"
#}
output "instance_sg" {
    value = "${aws_security_group.bitbucket_sg.id}"
}