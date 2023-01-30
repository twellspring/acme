# Acme Corporation POC
A Cloud Migration POC for Acme Company.

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
  ./manage_state create-stack dev
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
Make the following changes, then commit/PR/merge into main

### tfvars files
- Create a copy of anvil-support-dev-backend.tfvars
-   Update the region and key
- Create a copy of anvil-support-dev.tfvars
    - Update the region and environment

### Terraform Pipeline
- Create a copy of terraform-anvil-support-dev.yaml
    - Update the region and environment

### Build Pipeline
- Create a copy of build-anvil-support-dev.yaml
- Update the region and environment
- In the build job with section set `push: false` and add `force_ecs: true`

## Making Code Changes
- Update the code, commit/PR/merge
- Be sure to use [Semantic Versioning Prefixes](https://semver.org/) in your PR. If not, the release pipeline will fail


## Teardown
- Run the terraform destroy locally
```
cd terraform 
terraform init --backend-config=tfvars/anvil-support-dev-backend.tfvars 
terraform destroy -var-file=tfvars/anvil-support-dev.tfvars
```
- Destroy the Cloudformation resources
```
cd cloudformation
./manage_state delete-stack dev
```
- Delete the repository secrets
- Disable/Delete the Access Key (IAM / Users / your username / Security Credentials )