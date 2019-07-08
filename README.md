# terraform-microfocus-demo
A Terraform project to create compute instance for Micro Focus Demo

## Prerequisite
1. Set up `awscli`
2. Configure AWS credentials using `aws configure` command

## Getting Started
```
terraform init && terraform get && terraform apply -auto-approve
```

## Access to Instance
This module uses `microfocus-demo` keypair generated from AWS. Use `microfocus-demo.pem` to SSH to the instance.
```
ssh -i .ssh/microfocus-pem.ssh ec2-user@18.139.178.120
```

## Notes
1. Instance type is t3.large, although [t2.large is recommended by Micro Focus](https://admhelp.microfocus.com/mobilecenter/en/3.1/Content/off-prem%20AWS%20installation.htm).
2. AWS Linux 2 AMI is used, although [AWS Linux AMI is recommended by Micro Focus](https://admhelp.microfocus.com/mobilecenter/en/3.1/Content/off-prem%20AWS%20installation.htm).
3. This module is improvised from [dwmkerr/terraform-aws-openshift](https://github.com/dwmkerr/terraform-aws-openshift/tree/release/okd-3.11).
