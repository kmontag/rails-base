output "web_address" {
  value = "${module.application.elb_dns_name}"
}

output "instance_address" {
  value = "${module.application.instance_public_ip}"
}
