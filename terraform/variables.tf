variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name used to prefix resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "ami_id" {
  description = "AMI for the EC2 instance; empty = latest Amazon Linux 2023"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH"
  type        = string
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH to the EC2 instance"
  type        = list(string)
}

variable "services" {
  description = "Service names; one ECR repository per service per environment"
  type        = list(string)
}

variable "environments" {
  description = "Environments sharing the one cluster and the one registry (namespaces ivolve-<env>)"
  type        = list(string)
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
}

variable "eks_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public EKS API endpoint"
  type        = list(string)
}

variable "node_instance_types" {
  description = "Instance types for EKS worker nodes"
  type        = list(string)
}
