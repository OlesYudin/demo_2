# Output information about ECR repository
data "aws_ecr_repository" "ecr_repository" {
  name       = var.app_name # Get name of ECR repo for output info about this repository
  depends_on = [aws_ecr_repository.ecr_repository]
}
