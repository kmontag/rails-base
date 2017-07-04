output "host" {
  value = "${aws_db_instance.default.endpoint}"
}
