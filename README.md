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
ssh -i .ssh/microfocus-pem.ssh ec2-user@<EC2InstanceIP>
```

## Micro Focus Mobile Center Installation Notes
1. Follow the official guide [here](https://admhelp.microfocus.com/mobilecenter/en/3.1/Content/off-prem%20AWS%20installation.htm#mt-item-1)
2. Do not use Amazon Linux 2, it will error out when installing PostgreSQL due to missing libtinfo.so.5()(64bit)
3. Use `sudo`.
4. Need to apply patch to support iOS 12.2 and above
    - Mobile Center Linux Server patch: https://s3-us-west-1.amazonaws.com/hpmc/MC3.1/hotfix/3.10.00.0001/3.10.00.0001-hotfix-Linux_server_x64.zip
    - Mobile Center Connector (Windows x64) patch: https://s3-us-west-1.amazonaws.com/hpmc/MC3.1/hotfix/3.10.00.0001/3.10.00.0001-hotfix-Windows_connector_x64.zip

## Notes
1. Instance type is t3.large, although [t2.large is recommended by Micro Focus](https://admhelp.microfocus.com/mobilecenter/en/3.1/Content/off-prem%20AWS%20installation.htm).
2. AWS Linux 2 AMI is used, although [AWS Linux AMI is recommended by Micro Focus](https://admhelp.microfocus.com/mobilecenter/en/3.1/Content/off-prem%20AWS%20installation.htm).
3. This module is improvised from [dwmkerr/terraform-aws-openshift](https://github.com/dwmkerr/terraform-aws-openshift/tree/release/okd-3.11).

## UFT Installation Notes
1. When installing UFT, make sure to tick "Use DCOM for Automation Script", otherwise executing tests remotely might not work.