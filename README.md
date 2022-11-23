# terraform-alb-asg-ec2

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
ssh -i .ssh/my-key ec2-user@<PUBLIC_DNS_OR_IP>
```