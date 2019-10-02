# terraform-microfocus-demo
A Terraform project to create compute instance for Micro Focus Demo.

## Prerequisite
1. Set up `awscli`
2. Configure AWS credentials using `aws configure` command

## Getting Started

### Creating Infrastructure
```
terraform init && terraform get && terraform apply -auto-approve
```

### Access to Instance
This module uses `microfocus-demo` keypair generated from AWS. Use `microfocus-demo.pem` to SSH to the instance.
```
ssh -i ~/.ssh/microfocus-demo.pem ec2-user@<EC2InstanceIP>
```

### Before Installing Micro Focus
1. `sudo yum update`
2. `sudo pip install gdown` (for download from Google Drive later)
3. Install Apache 2.4
    ```
    # Install
    sudo yum install -y httpd24 httpd24-tools mod24_ssl

    # After installation set Apache to auto-start.
    sudo chkconfig httpd on
    ```
3. Add `<VirtualHost>` by `sudo vi /etc/httpd/conf/httpd.conf`
    ```
    <VirtualHost *:80>
    ServerName mobilecenter.liquiddelivery.net
    </VirtualHost>
    ```
4. "Let's Encrypt" using CertBot (Ref: https://stackoverflow.com/a/56640405/)
    ```
    # Download CertBot
    wget https://dl.eff.org/certbot-auto
    sudo mv certbot-auto /usr/local/bin/certbot-auto
    sudo chown root /usr/local/bin/certbot-auto && sudo chmod 0755 /usr/local/bin/certbot-auto

    # Install Certificate
    sudo /usr/local/bin/certbot-auto certonly --apache --debug -d mobilecenter.liquiddelivery.net

    # Dry run certificate renewal
    sudo /usr/local/bin/certbot-auto renew --dry-run

    # Configure auto-renewal cron job using `sudo vi /etc/crontab`
    0 0,12 * * * python -c 'import random; import time; time.sleep(random.random() * 3600)' && /usr/local/bin/certbot-auto renew 
    ```
5. Configure apache using `sudo vi /etc/httpd/conf.d/ssl.conf`
    ```
    SSLCertificateFile /etc/letsencrypt/live/mobilecenter.liquiddelivery.net/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/mobilecenter.liquiddelivery.net/privkey.pem
    Include /etc/letsencrypt/options-ssl-apache.conf
    SSLProxyEngine On
    ```
6. Start Apache 2.4 server
    ```
    sudo service httpd start
    ```
7. Verify the setup by going to https://mobilecenter.liquiddelivery.net/
8. `sudo vi /etc/sysconfig/network`
    ```
    HOSTNAME=mobilecenter.liquiddelivery.net
    ```
9. `sudo reboot`
10. `sudo vi /etc/hosts`
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

Official Guide: [here](https://admhelp.microfocus.com/mobilecenter/en/3.1/Content/off-prem%20AWS%20installation.htm#mt-item-1)

1. Download MC310-16862_Linux_Server
    ```
    # Install gdown (if not yet), download installation file, unzip
    sudo pip install gdown
    gdown https://drive.google.com/uc?id=1rvpRkm0o8cZjiLJha8GBFbphFh4Unf4B
    mkdir MC310-16862_Linux_Server && unzip -d MC310-16862_Linux_Server/ MC310-16862_Linux_Server.zip
    ```
2. Run installation
    ```
    # Install
    sudo ./MC310-16862_Linux_Server/SERVER/install_server-x64-3.10.00.00-242.bin -DUSER_INPUT_INSTALL_AWS_MODE=1
    ```
3. `!!!` Do not use existing user -> your installation would be interrupted and cannot be completed. Let it create a new user called `mc`.
4. Need to apply patch to support iOS 12.2 and above
    - Mobile Center Linux Server patch
        ```
        wget https://s3-us-west-1.amazonaws.com/hpmc/MC3.1/hotfix/3.10.00.0001/3.10.00.0001-hotfix-Linux_server_x64.zip
        mkdir 3.10.00.0001-hotfix-Linux_server_x64 && unzip -d 3.10.00.0001-hotfix-Linux_server_x64/ 3.10.00.0001-hotfix-Linux_server_x64.zip
        sudo ./3.10.00.0001-hotfix-Linux_server_x64/server_patcher-x64-3.10.00.0001-294.bin
        ```
    - Mobile Center Connector (Windows x64) patch: [here](https://s3-us-west-1.amazonaws.com/hpmc/MC3.1/hotfix/3.10.00.0001/3.10.00.0001-hotfix-Windows_connector_x64.zip)
5. Use certificate, https://admhelp.microfocus.com/mobilecenter/en/3.1/Content/SSL.htm#Using
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


## UFT Installation Notes
1. When installing UFT, make sure to tick "Use DCOM for Automation Script", otherwise executing tests remotely might not work.