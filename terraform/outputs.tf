output "jenkins_role_arn" {
  description = "IAM role of the Jenkins EC2 instance"
  value       = module.ec2.iam_role_arn
}

output "jenkins_instance_profile" {
  description = "Instance profile attached to the Jenkins EC2 instance"
  value       = module.ec2.instance_profile_name
}

output "eks_cluster_role_arn" {
  description = "IAM role of the EKS control plane"
  value       = module.eks.cluster_role_arn
}

output "eks_node_role_arn" {
  description = "IAM role of the EKS worker nodes"
  value       = module.eks.node_role_arn
}

output "eks_cluster_name" {
  description = "Cluster name for: aws eks update-kubeconfig --name <this>"
  value       = module.eks.cluster_name
}

output "jenkins_public_ip" {
  description = "Public IP of the Jenkins host"
  value       = module.ec2.ec2_public_ip
}

output "ecr_repository_urls" {
  description = "ECR repository URLs by name"
  value       = module.ecr.repository_urls
}

output "vault_kms_key_id" {
  description = "KMS key Vault uses for auto-unseal (helm install --set server.extraEnvironmentVars.VAULT_AWSKMS_SEAL_KEY_ID=...)"
  value       = module.eks.vault_kms_key_id
}
