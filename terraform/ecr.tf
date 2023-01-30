resource "aws_ecr_repository" "repo" {
  name = local.prefix
}
