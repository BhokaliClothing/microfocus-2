# terraform-microfocus-demo
* A Terraform project to create compute instance for Micro Focus Demo.
* The Terraform state is stored at an S3 bucket to facilitate team collaboration.

## Prerequisite
1. Set up `awscli`
2. Configure AWS credentials using `aws configure` command
3. Prepare an AWS Key Pair, use the key pair name for `key_pair_name` variable.

## Getting Started

### Creating Infrastructure
```
terraform init && terraform get && terraform apply -auto-approve
```

### Access to Instance
This module uses `microfocus-demo` keypair generated from AWS. Use `microfocus-demo.pem` to SSH to the instance.
```
ssh -i ~/.ssh/microfocus-demo.pem centos@<EC2InstanceIP>
```

### Before Installing Micro Focus (WIP)
1. `sudo yum update`
2. `sudo yum install epel-release` (software packages for Linux distribution including CentOS)
3. `sudo yum install wget`
4. `sudo yum -y install python-pip` (to install pip)
5. `sudo pip install gdown` (for download from Google Drive later)
6. "Let's Encrypt" using CertBot (Ref: https://stackoverflow.com/a/56640405/)
    ```
    # Download CertBot
    wget https://dl.eff.org/certbot-auto
    sudo mv certbot-auto /usr/local/bin/certbot-auto
    sudo chown root /usr/local/bin/certbot-auto && sudo chmod 0755 /usr/local/bin/certbot-auto

    # Install Certificate
    sudo /usr/local/bin/certbot-auto certonly --standalone --debug -d mobilecenter.liquiddelivery.net

    # Dry run certificate renewal
    sudo /usr/local/bin/certbot-auto renew --dry-run

    # Configure auto-renewal cron job using crontab
    echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && /usr/local/bin/certbot-auto renew" | sudo tee -a /etc/crontab > /dev/null
    ```
7. `sudo hostnamectl set-hostname mobilecenter.liquiddelivery.net`
8. `sudo vi /etc/hosts`
    ```
    $ sudo cat /etc/hosts
    127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 mobilecenter.liquiddelivery.net
    ::1         localhost6 localhost6.localdomain6
    ```

### Installing Micro Focus Mobile Center

> #### Notes
> 1. Do not use Amazon Linux 2, it will error out when installing PostgreSQL due to missing libtinfo.so.5()(64bit)
> 2. Instance type is t3.large, although [t2.large is recommended by Micro Focus](https://admhelp.microfocus.com/mobilecenter/en/3.1/Content/off-prem%20AWS%20installation.htm).
> 3. This module is improvised from [dwmkerr/terraform-aws-openshift](https://github.com/dwmkerr/terraform-aws-openshift/tree/release/okd-3.11).
> 4. Do not start the service after installation, needed to rename "awsChangePassword.sh" to other name first to avoid hostname(FQDN) from changing.

Official Guide: [here](https://admhelp.microfocus.com/mobilecenter/en/3.2/Content/off-prem%20AWS%20installation.htm)

1. Download Mobile Center 3.2
    ```
    # Install gdown (if not yet), download installation file, unzip
    sudo pip install gdown
    gdown https://drive.google.com/uc?id=1n3vIA7jCtXvWLKapjMWAGIshpXLFrHtU
    mkdir MC320-19152_Linux_Server && unzip -d MC320-19152_Linux_Server/ install-server-linux-x64-3.20-19152.zip
    ```
2. Run installation
    ```
    # Install
    sudo ./MC320-19152_Linux_Server/install_server-x64-3.20.00.00-9.bin -DUSER_INPUT_INSTALL_AWS_MODE=1
    ```
3. `!!!` Do not use existing user -> your installation would be interrupted and cannot be completed. Let it create a new user called `mc`.
4. Use certificate, https://admhelp.microfocus.com/mobilecenter/en/3.2/Content/SSL.htm#Using
    ```
    # Create PFX certificate
    sudo su
    cd /etc/letsencrypt/live/mobilecenter.liquiddelivery.net/
    openssl pkcs12 -export -out certificate.pfx -inkey privkey.pem -in cert.pem -certfile chain.pem

    # Import certificate
    cd /opt/mc/server/Security
    sudo ./importCA.sh
    # /etc/letsencrypt/live/mobilecenter.liquiddelivery.net/certificate.pfx
    ```
5. Rename awsChangePassword.sh
   ```
   sudo mv /opt/mc/server/bin/awsChangePassword.sh /opt/mc/server/bin/awsChangePassword_bak.sh
   ```
6. Run Micro Focus Service
   ```
   sudo service mc start
   ```
   
### Installing AutoPass
1. Download from Google Drive, unzip, execute
    ```
    gdown https://drive.google.com/uc?id=11dk_GOpuVg707bjWJzHHqKwAF1WuZn9V
    unzip autopass-10.9.0.zip
    cd autopass-10.9.0/AutoPassLicenseServer\ 10.9.0/UNIX/ && sudo chmod 0755 setup.bin
    sudo ./setup.bin
    ```
2. Sample pre-installation summary
    ```
    ===============================================================================
    Pre-Installation Summary
    ------------------------

    Please Review the Following Before Continuing:

    Product Name:
        AutoPass License Server 10.9.0

    Install Folder:
        /opt/autopass

    Link Folder:
        /usr/bin

    Java VM to be Used by Installed Product:
        /tmp/install.dir.2039/Linux/resource/jre

    Data Dir
        "/var/opt/autopass"

    Disk Space Information (for Installation Target):
        Required:     234.66 MegaBytes
        Available: 32,257.53 MegaBytes

    ...

    AutoPass License Server 10.9.0 GUI can be accessed at :
    https://<Host/IP address>:5814/autopass
    ```
3. Reconfigure Tomcat server

    1. Configure SSL certificate
        ```
        # From
        keystoreFile="/opt/autopass/apls/apls/conf/keystore.jks" keystorePass="Na1@Rp$" keyAlias="aptomcat"
        # To
        keystoreFile="/etc/letsencrypt/live/mobilecenter.liquiddelivery.net/certificate.pfx" keystorePass="password" keystoreType="PKCS12"
        ```
    2. Update Tomcat server port number from 5814 to 15814.
        ```
        # From
        port="5814"
        # To
        port="15814"
        ```
4. Restart service
    ```
    sudo service aplsLicenseServer restart
    ```
    
### Updating TSL version
1. sudo su 
	- make yourself as root
2. ls -la/etc/nginx
3. nginx -t
	-check if it's successful
4. vi /etc/nginx/nginx.conf
5. #original line
	-commented the original line and paste in the new line
6. :wq
	- save and out from the file


### UFT Installation Notes
1. When installing UFT, make sure to tick "Use DCOM for Automation Script", otherwise executing tests remotely might not work.

### Additional Notes
#### Security Tips for Apache Server

> Note: Apache Server is no longer required as part of the solution

1. Use Apache Server 2.4 (httpd24) - Because 2.2 (httpd) is no longer maintained/recommended, see http://archive.apache.org/dist/httpd/Announcement2.2.html
2. Implement SSL using Let's Encrypt - https://letsencrypt.org/
	Note: Configure cron job for auto cert renewal
3. Reconfigure all .conf files, including /etc/letsencrypt/options-ssl-apache.conf created by Let's Encrypt
	* Update supported SSLProtocol, e.g. exclude TLSv1.0
	* Update SSLCipherSuite, e.g. do not allow DES, 3DES, IDEA, RC2
	* Sample reference: https://ssl-config.mozilla.org/#server=apache&server-version=2.4.39&config=intermediate
