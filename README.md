# terraform-alb-asg-nginx
This project deploys Nginx on Amazon Linux 2022 instances within a load-balanced autoscaling group, similar to the architecture shown in [this AWS tutorial](https://docs.aws.amazon.com/autoscaling/ec2/userguide/tutorial-ec2-auto-scaling-load-balancer.html) using Terraform.

## Prerequisites
1. [Terraform installed](https://developer.hashicorp.com/terraform/downloads)
2. [AWS credentials configured](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)

## Directions
Create SSH key:
```
mkdir .ssh
ssh-keygen -t rsa -b 4096 -m pem -f .ssh/tf-alb-asg-ec2-dev-key
```
Create a `terraform.tfvars` file with the following content:
```
environment   = "dev"
instance_type = "t2.micro"
project_name  = "tf-alb-asg-ec2"
ssh_key_path  = ".ssh"
region        = "us-east-1"
```
Deploy infrastructure:
```
terraform init
terraform apply
```
## Access website
Open the application url in browser:
```
open $(terraform output -raw application_url)
```
## Access instances
Choose the public IP from one of the instance displayed on the webpage and ssh as ec2-user`:
```
ssh -i .ssh/tf-alb-asg-ec2-dev-key ec2-user@<PUBLIC_DNS_OR_IP>
```
