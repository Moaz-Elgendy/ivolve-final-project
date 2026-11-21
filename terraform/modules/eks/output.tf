output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "API server endpoint for the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority" {
  description = "Certificate authority data for the EKS cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "EKS-managed security group shared by the control plane and worker nodes"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "node_role_arn" {
  description = "ARN of the IAM role assigned to EKS worker nodes"
  value       = aws_iam_role.nodes.arn
}

output "cluster_role_arn" {
  description = "ARN of the IAM role assumed by the EKS control plane"
  value       = aws_iam_role.cluster.arn
}

output "node_role_name" {
  description = "Name of the IAM role assigned to EKS worker nodes"
  value       = aws_iam_role.nodes.name
}

output "vault_kms_key_id" {
  description = "KMS key ID used by Vault auto-unseal"
  value       = aws_kms_key.vault.key_id
}

output "ebs_csi_role_arn" {
  description = "ARN of the IAM role used by the EBS CSI driver"
  value       = aws_iam_role.ebs_csi.arn
}
