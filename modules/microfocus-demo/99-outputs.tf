//  Output some useful variables for quick SSH access etc.
output "microfocus-demo-public_ip" {
  value = "${aws_eip.microfocus-demo-eip.public_ip}"
}
output "microfocus-demo-private_dns" {
  value = "${aws_instance.microfocus-demo.private_dns}"
}
output "microfocus-demo-private_ip" {
  value = "${aws_instance.microfocus-demo.private_ip}"
}
