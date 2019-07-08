//  Define the VPC.
resource "aws_vpc" "microfocus-demo" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "Micro Focus Demo VPC"
    )
  )}"
}

//  Create an Internet Gateway for the VPC.
resource "aws_internet_gateway" "microfocus-demo" {
  vpc_id = "${aws_vpc.microfocus-demo.id}"

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "Micro Focus Demo IGW"
    )
  )}"
}

//  Create a public subnet.
resource "aws_subnet" "microfocus-demo-public-subnet" {
  vpc_id                  = "${aws_vpc.microfocus-demo.id}"
  cidr_block              = "${var.subnet_cidr}"
  availability_zone       = "${data.aws_availability_zones.azs.names[0]}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.microfocus-demo"]

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "Micro Focus Demo Public Subnet"
    )
  )}"
}

//  Create a route table allowing all addresses access to the IGW.
resource "aws_route_table" "microfocus-demo-public" {
  vpc_id = "${aws_vpc.microfocus-demo.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.microfocus-demo.id}"
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "Micro Focus Demo Public Route Table"
    )
  )}"
}

//  Now associate the route table with the public subnet - giving
//  all public subnet instances access to the internet.
resource "aws_route_table_association" "microfocus-demo-public-subnet" {
  subnet_id      = "${aws_subnet.microfocus-demo-public-subnet.id}"
  route_table_id = "${aws_route_table.microfocus-demo-public.id}"
}
