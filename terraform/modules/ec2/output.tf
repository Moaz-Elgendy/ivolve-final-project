output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

output "iam_role_name" {
  description = "Name of the Jenkins instance IAM role"
  value       = aws_iam_role.jenkins.name
}

output "iam_role_arn" {
  description = "ARN of the Jenkins instance IAM role"
  value       = aws_iam_role.jenkins.arn
}

output "instance_profile_name" {
  description = "Name of the Jenkins instance profile"
  value       = aws_iam_instance_profile.jenkins.name
}
