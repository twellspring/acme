data "aws_availability_zones" "this" {
  state = "available"
}

locals {
  azs             = [for loop in [0, 1, 2] : data.aws_availability_zones.this.names[loop]]
  private_subnets = [for loop in [0, 1, 2] : cidrsubnet(var.vpc_cidr, 8, loop)]
  public_subnets  = [for loop in [3, 4, 5] : cidrsubnet(var.vpc_cidr, 8, loop)]
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = local.prefix
  cidr            = var.vpc_cidr
  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway = true

  tags = {
    Environment = "dev"
  }
}
