
# Terraform

## Pre-requisites

- AMI
- Terraform
- Git
- Pem-key

## What is Terraform?

- Terraform is a Orchestration Tool, that is part of infrastructure as code.

- Chef and Packer are more on the **Configuration Management** side and creating
immutable AMIs. immutable is when you are unable to make changes.

- Terraform sits on the Orchestration side, while focusing on the creation of networks and complex systems and deploys AMIs

An AMI is a blue print (snap shot) of an instance:
- Operating System
- Data and Storage
- All the packages and exact state of the machine when it was created.

## Running Terraform

- To run the commands in Terraform:
````
terraform plan
````

 - To create your EC2 Instance and get the App running automatically:
````
terraform apply
````

- To destroy to process on Terraform:
````
terraform destroy
````

- The App will be running via the Public IP address of the Instance it created.
- You'll need to press the following command on your keyboard 'ctrl' + 'c' at the
same time to cancel the process.

## To Load the apply

- Copy the Public IP Address from the instances generating. Heres an example of an Public IP Address
````
xx.yyy.x.y
````
- If anymore difficulties then you'll have to enter the machine by writing
````
ssh -i /.ssh/<Pem-key> ubuntu@<xx.yyy.x.y>
````
- Once entered the machine do the following command
````
cd /home/ubuntu/app
npm start
````

## 2-Tier Architecture (App & DB)

- Terraform will generate two different instances, one for the App and the other one for the DB.
- These instances will be able to communicate with each other, and this will be known as a 2-Tier Architecture.
