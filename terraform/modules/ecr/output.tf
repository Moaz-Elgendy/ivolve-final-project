output "repository_urls" {
  description = "Map of repository names to repository URLs"
  value = {
    for name, repository in aws_ecr_repository.main : name => repository.repository_url
  }
}

output "repository_arns" {
  description = "Map of repository names to repository ARNs"
  value = {
    for name, repository in aws_ecr_repository.main : name => repository.arn
  }
}

output "repository_registry_ids" {
  description = "Map of repository names to AWS registry IDs"
  value = {
    for name, repository in aws_ecr_repository.main : name => repository.registry_id
  }
}
