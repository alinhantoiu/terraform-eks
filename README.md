# terraform-eks

PREREQUISITES

Install terraform

https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform

Install aws cli

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

Create an IAM User

Log in to the AWS Management Console.
Go to IAM > Users > Add users.
Name the user (e.g., terraform-user) and enable Programmatic access to generate an Access Key ID and Secret Access Key.
Attach the AdministratorAccess policy for full access and create an Access Key

Configure

Use the AWS CLI by running aws configure and entering the credentials
aws configure

Provision Infrastructure

Go into terraform folder

cd terraform
terraform init
terraform plan

Run terraform apply command

terraform apply -auto-approve