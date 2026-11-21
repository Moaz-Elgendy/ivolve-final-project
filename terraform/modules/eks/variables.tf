variable "project_name" {
  description = "Project name used to name EKS resources"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs used by EKS; provide subnets in at least two availability zones"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two private subnet IDs from different availability zones must be provided."
  }
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.35"
}

variable "endpoint_private_access" {
  description = "Whether the EKS API server has a private endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the EKS API server has a public endpoint"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public EKS API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_instance_types" {
  description = "EC2 instance types used by the EKS managed node group"
  type        = list(string)
  default     = ["m7i-flex.large"]
}

variable "capacity_type" {
  description = "Capacity type for worker nodes: ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.capacity_type)
    error_message = "capacity_type must be ON_DEMAND or SPOT."
  }
}
