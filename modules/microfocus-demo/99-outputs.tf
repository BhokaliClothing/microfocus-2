//  Output some useful variables for quick SSH access etc.
/* output "master-public_ip" {
  value = "${aws_eip.master_eip.public_ip}"
}
output "master-private_dns" {
  value = "${aws_instance.master.private_dns}"
}
output "master-private_ip" {
  value = "${aws_instance.master.private_ip}"
}

output "node1-public_ip" {
  value = "${aws_eip.node1_eip.public_ip}"
}
output "node1-private_dns" {
  value = "${aws_instance.node1.private_dns}"
}
output "node1-private_ip" {
  value = "${aws_instance.node1.private_ip}"
}

output "node2-public_ip" {
  value = "${aws_eip.node2_eip.public_ip}"
}
output "node2-private_dns" {
  value = "${aws_instance.node2.private_dns}"
}
output "node2-private_ip" {
  value = "${aws_instance.node2.private_ip}"
} */

output "microfocus-demo-public_ip" {
  value = "${aws_eip.microfocus-demo-eip.public_ip}"
}
output "microfocus-demo-private_dns" {
  value = "${aws_instance.microfocus-demo.private_dns}"
}
output "microfocus-demo-private_ip" {
  value = "${aws_instance.microfocus-demo.private_ip}"
}
