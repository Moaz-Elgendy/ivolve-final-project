variable "ami_id" {
  description = "AMI ID used to launch the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type, such as t3.micro"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the EC2 instance will be launched"
  type        = string
}

variable "key_name" {
  description = "Name of the EC2 key pair used for SSH access"
  type        = string
}

variable "project_name" {
  description = "Project name used to prefix resource tags"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the EC2 security group is created"
  type        = string
}

variable "root_volume_size" {
  description = "Root volume size in GiB (docker images, Maven cache, Trivy DB)"
  type        = number
  default     = 30
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the EC2 instance over SSH"
  type        = list(string)
}
