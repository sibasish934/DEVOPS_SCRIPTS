#!/bin/bash

# Installing CodeDeploy Agent
sudo yum update
sudo yum install ruby -y

# Download the agent (replace the region)
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent status