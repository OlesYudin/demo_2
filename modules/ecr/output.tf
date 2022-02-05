# Output regestry id
output "regestry_id" {
  value = data.aws_ecr_repository.ecr_repository.registry_id
}
# Output URL of registry
output "regestry_url" {
  value = "${data.aws_ecr_repository.ecr_repository.registry_id}.dkr.ecr.${var.region}.amazonaws.com/${var.app_name}"
}
