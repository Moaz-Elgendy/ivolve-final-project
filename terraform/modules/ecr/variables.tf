variable "repository_names" {
  description = "Names of the ECR repositories to create"
  type        = list(string)

  validation {
    condition     = length(var.repository_names) > 0
    error_message = "At least one repository name must be provided."
  }
}

variable "image_tag_mutability" {
  description = "Tag mutability setting for repositories; valid values are MUTABLE or IMMUTABLE"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Whether to scan container images automatically when pushed"
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "Whether to delete repositories even when they contain images"
  type        = bool
  default     = false
}

variable "encryption_type" {
  description = "ECR repository encryption type; valid values are AES256 or KMS"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be either AES256 or KMS."
  }
}
