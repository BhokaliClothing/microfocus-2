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
ssh -i ~/.ssh/microfocus-demo.pem ec2-user@<EC2InstanceIP>
```

## Before Installing
1. sudo yum update
2. Install Apache 2.4
```
# Install
sudo yum install -y httpd24 httpd24-tools mod24_ssl
# After installation set Apache to auto-start and also start once.
sudo chkconfig httpd on
sudo service httpd start
```
3. Add `<VirtualHost>`
```
sudo vi /etc/httpd/conf/httpd.conf
```
4. "Let's Encrypt" using CertBot (Ref: https://stackoverflow.com/a/56640405/)
```
# Download CertBot
wget https://dl.eff.org/certbot-auto
sudo mv certbot-auto /usr/local/bin/certbot-auto
sudo chown root /usr/local/bin/certbot-auto
sudo chmod 0755 /usr/local/bin/certbot-auto

# Install Certificate
sudo /usr/local/bin/certbot-auto certonly --apache --debug -d mobilecenter.liquiddelivery.net

# Dry run certificate renewal
sudo /usr/local/bin/certbot-auto renew --dry-run

# Configure auto-renewal cron job at /etc/crontab
0 0,12 * * * python -c 'import random; import time; time.sleep(random.random() * 3600)' && /usr/local/bin/certbot-auto renew 
```

## Micro Focus Mobile Center Installation Notes
0. Download MC310-16862_Linux_Server
```
# Install gdown, download installation file, unzip
sudo pip install gdown
gdown https://drive.google.com/uc?id=1rvpRkm0o8cZjiLJha8GBFbphFh4Unf4B
mkdir MC310-16862_Linux_Server && unzip -d MC310-16862_Linux_Server/ MC310-16862_Linux_Server.zip

# Install
sudo ./MC310-16862_Linux_Server/SERVER/install_server-x64-3.10.00.00-242.bin -DUSER_INPUT_INSTALL_AWS_MODE=1
```
1. Follow the official guide [here](https://admhelp.microfocus.com/mobilecenter/en/3.1/Content/off-prem%20AWS%20installation.htm#mt-item-1)
2. Do not use Amazon Linux 2, it will error out when installing PostgreSQL due to missing libtinfo.so.5()(64bit)
3. Use `sudo`.
4. !!! Do not use existing user -> your installation would be interrupted and cannot be completed.
5. Need to apply patch to support iOS 12.2 and above
    - Mobile Center Linux Server patch: https://s3-us-west-1.amazonaws.com/hpmc/MC3.1/hotfix/3.10.00.0001/3.10.00.0001-hotfix-Linux_server_x64.zip
    - Mobile Center Connector (Windows x64) patch: https://s3-us-west-1.amazonaws.com/hpmc/MC3.1/hotfix/3.10.00.0001/3.10.00.0001-hotfix-Windows_connector_x64.zip
6. Use certificate, https://admhelp.microfocus.com/mobilecenter/en/3.1/Content/SSL.htm#Using
```
# Create certificate (sample command only)
openssl pkcs12 -export -in fullchain.pem -inkey privkey.pem -out keystore.p12 -CAfile chain.pem

# Install certificate
cd /opt/mc/server/Security
sudo ./installCA.sh
```

## Notes
1. Instance type is t3.large, although [t2.large is recommended by Micro Focus](https://admhelp.microfocus.com/mobilecenter/en/3.1/Content/off-prem%20AWS%20installation.htm).
2. This module is improvised from [dwmkerr/terraform-aws-openshift](https://github.com/dwmkerr/terraform-aws-openshift/tree/release/okd-3.11).

## UFT Installation Notes
1. When installing UFT, make sure to tick "Use DCOM for Automation Script", otherwise executing tests remotely might not work.