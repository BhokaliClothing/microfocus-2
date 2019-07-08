//  Setup the core provider information.
provider "aws" {
  region  = "ap-southeast-1"
}

//  Create the OpenShift cluster using our module.
module "microfocus-demo" {
  source          = "./modules/microfocus-demo"
  region          = "ap-southeast-1"
  amisize         = "t3.large"
  vpc_cidr        = "10.0.0.0/16"
  subnet_cidr     = "10.0.1.0/24"
  // key_name        = "microfocus-demo"
  // public_key_path = "${var.public_key_path}"
  // cluster_name    = "microfocus-demo-cluster"
  // cluster_id      = "microfocus-demo-cluster-${var.region}"
}

//  Output some useful variables for quick SSH access etc.
/* output "master-url" {
  value = "https://${module.microfocus-demo.master-public_ip}.xip.io:8443"
}
output "master-public_ip" {
  value = "${module.microfocus-demo.master-public_ip}"
} */
output "microfocus-demo-public_ip" {
  value = "${module.microfocus-demo.microfocus-demo-public_ip}"
}
