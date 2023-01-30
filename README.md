# Acme Corporation POC
A Cloud Migration POC for Acme Company. This will create a publicly accessible anvil support portal example application inside of ECS. 

## What Get's Created
- An S3 bucket and Dynamo DB table to hold Terraform state
- AWS VPC (subnets, routing tables, internet gateway, NAT gateway)
- ECS Deployment (task definition, cluster, service, tasks)
- Load Balancer (load balancer, target groups, elastic IPs)
- Docker image of the Python sample app, uploaded to ECR
- Security Groups needed to provide access from the internet and between components
- IAM Roles needed to allow ECS to pull images from ECR and to create tasks

## Requirements
- Terraform >= 1.3
- docker >= 20.10.20
- git
- aws cli >= 2.9
- An admin AWS login and your CLI setup with AWS access

## Initial setup
### SSL
- Create an SSL Certificate for the domain to be used

### AWS
- Create an Access Key (IAM / Users / your username / Security Credentials )
- Create Infrastructure needed to save Terraform state 
  ```
  cd cloudformation
  ./manage_state.sh create-stack dev
  ```

### GITHUB
- Create a Personal Access Token (User Settings / Developer Settings / Personal Access Token)
- Create the following secrets using the above values ( Repo settings / Secrets and Variables / Actions )
  - PAT
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
  - TF_VAR_TLS_CERTIFICATE
  - TF_VAR_TLS_KEY
  - TF_VAR_TLS_CHAIN

## Creating a new environment

### Update tfvars files
- Create a copy of anvil-support-dev-backend.tfvars
  - Update the environment value in the key
- Create a copy of anvil-support-dev.tfvars
    - Update the environment

### Update Terraform Pipeline
- Create a copy of terraform-anvil-support-dev.yaml
    - Update the environment value in the name
    - In the job with section, update the environment

### Update Build Pipeline
- Create a copy of build-anvil-support-dev.yaml
  - Update name
  - In the job with section, update the environment


### PR and DNS
- Create a PR with all the above changes and merge to main
- Once the new environment is created, Find the load balancer's dns name via AWS console or `aws elb describe-load-balancers`
- In your DNS hosting provider, create a CNAME pointing to the load balancer dns name

### Trigger Build
Since the new environment also has a new ECR (shortcoming of demo), there is no image for this new ECS to pull down from its repo. 
- In Github Actions, Choose the newly created build job
- Run Workflow
  - Specify the latest release

## Making Code Changes
- Update the code, commit/PR/merge
- Be sure to use [Semantic Versioning Prefixes](https://semver.org/) in your PR. If not, the release pipeline will fail


## Destroy an existing environment
For each environment created:
- In AWS ECR delete all images in the `anvil-support-<env>` repo
- Run the terraform destroy locally
```
cd terraform 
terraform init --backend-config=tfvars/anvil-support-<env>-backend.tfvars --reconfigure
terraform destroy --var-file=tfvars/anvil-support-<env>.tfvars
```
- Delete the environment tfvars files and terraform/build pipelines
- Commit, PR, merge

## Teardown
- destroy all environments per above
- Destroy the Cloudformation resources
```
cd cloudformation
./manage_state.sh delete-stack dev
```
- Delete the repository secrets
- Disable/Delete the Access Key (IAM / Users / your username / Security Credentials )
- Delete the DNS name