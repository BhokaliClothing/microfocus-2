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

resource "aws_flow_log" "vpc_flow_logs" {
  log_destination = "${aws_cloudwatch_log_group.vpc_flow_log_group.arn}"
  iam_role_arn    = "${aws_iam_role.vpc_flow_role.arn}"
  vpc_id          = "${aws_vpc.microfocus-demo.id}"
  traffic_type    = "ALL"
  depends_on      = ["aws_vpc.microfocus-demo", "aws_iam_role.vpc_flow_role", "aws_cloudwatch_log_group.vpc_flow_log_group"]
}

resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name       = "${var.project_name}_vpc_flow_log_group"
  depends_on = ["aws_vpc.microfocus-demo"]

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "VPC Flow Logs Group"
    )
  )}"
}

resource "aws_iam_role" "vpc_flow_role" {
  name       = "${var.project_name}_vpc_flow_role"
  depends_on = ["aws_vpc.microfocus-demo"]

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "Role for VPC Flow Logs"
    )
  )}"
}

resource "aws_iam_role_policy" "vpc_flow_policy" {
  name = "${var.project_name}_vpc_flow_policy"
  role = "${aws_iam_role.vpc_flow_role.id}"
  depends_on = ["aws_vpc.microfocus-demo"]

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}