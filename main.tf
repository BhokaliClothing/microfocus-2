//  Setup the core provider information.
provider "aws" {
  region  = "ap-southeast-1"
}

//  Create the OpenShift cluster using our module.
module "microfocus-demo" {
  project_name    = "microfocus-demo"
  source          = "./modules/microfocus-demo"
  region          = "ap-southeast-1"
  amisize         = "t3.large"
  vpc_cidr        = "10.0.0.0/16"
  subnet_cidr     = "10.0.1.0/24"
  key_name        = "microfocus-demo"
}

output "microfocus-demo-public_ip" {
  value = "${module.microfocus-demo.microfocus-demo-public_ip}"
}
