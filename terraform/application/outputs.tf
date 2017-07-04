output "instance_public_ip" {
  value = "${aws_instance.application.public_ip}"
}

output "elb_dns_name" {
  value = "${aws_elb.default.dns_name}"
}
