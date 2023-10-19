#App Connectorの作成
resource "aws_instance" "app_connector" {
  ami           = "ami-05b60713705a935c2"
  instance_type = "t3.medium" 
  subnet_id = aws_subnet.private_subnet1.id
  user_data = base64encode(local.command)
  key_name = "zsdemo"
  tags = {
    Name = "${var.vpc_name}-ec2"
  }
}

locals {
  command = <<EOF
#!/bin/bash
#Stop the App Connector service which was auto-started at boot time
systemctl stop zpa-connector
#Create a file from the App Connector provisioning key created in the ZPA Admin Portal
#Make sure that the provisioning key is between double quotes
echo "${var.provision_key}" > /opt/zscaler/var/provision_key
#Run a yum update to apply the latest patches
yum update -y
#Start the App Connector service to enroll it in the ZPA cloud
systemctl start zpa-connector
#Wait for the App Connector to download latest build
sleep 60
#Stop and then start the App Connector for the latest build
systemctl stop zpa-connector
systemctl start zpa-connector
   EOF
}
