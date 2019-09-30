//  Create an SSH keypair
/* resource "aws_key_pair" "keypair" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
} */

//  Create Elastic IP for the compute node
resource "aws_eip" "microfocus-demo-eip" {
  instance = "${aws_instance.microfocus-demo.id}"
  vpc      = true
}

resource "aws_instance" "microfocus-demo" {
  # This is a an Amazon Linux 2 AMI with encrypted volume customized for ATA AWS account.
  // ami                  = "ami-02a5672728db47f48"
  # This is a an Amazon Linux AMI with encrypted volume customized for ATA AWS account.
  ami                  = "ami-01bbcc74d6f8488cc"
  instance_type        = "${var.amisize}"
  subnet_id            = "${aws_subnet.microfocus-demo-public-subnet.id}"
  iam_instance_profile = "${aws_iam_instance_profile.microfocus-demo-instance-profile.id}"

  vpc_security_group_ids = [
    "${aws_security_group.microfocus-demo-vpc.id}",
    "${aws_security_group.microfocus-demo-ssh.id}",
    "${aws_security_group.microfocus-demo-public-ingress.id}",
    "${aws_security_group.microfocus-demo-public-egress.id}"
  ]

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }

  key_name = "microfocus-demo"

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "Micro Focus Demo Compute Node"
    )
  )}"
}

