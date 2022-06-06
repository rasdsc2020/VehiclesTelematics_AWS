# VehiclesTelematics_AWS
 The designing of this application aims to build a real-time data-intensive application using AWS services for the use case of vehicle telematics data to identifying over speeding two-wheeler and four-wheeler vehicles.


  ## Prerequisites:

- AWS Account
- IAM User with Access Key & Secret Key
- Terraform ([Download](https://www.terraform.io/downloads))

## 1. Configure local machine:

- Clone this repository
- Provide the access key, secret key and region as requested in variable.tf and Datagenerator.py
- change number of records of vehicle data in Datagenerator.py
- save terraform.exe in current working directory

## 2. Setup AWS Infrastructure:

- Open terminal(linux)/command prompt(windows)
- Run terraform init command
- Run terraform plan command. To see the changes will be made by terraform
- Run terraform apply command. Provide yes as input when asked and hit enter 

## 3. Send data to infrastructure

- Exceute Datagenerator.py from any IDE (VS Code)
   - **Note: you need faker and boto3 python libraries**
- Check infratsructure on your cloud
- After five minutes check data in S3 buckets


**Please note:** Extra costs may incur depending on the usage