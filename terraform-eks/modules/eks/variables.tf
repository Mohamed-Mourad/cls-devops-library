// Variables for the EKS module.
// The following variables MUST be provided via the calling configuration (e.g., environments/dev/main.tf)
// since their values are coming from other modules' outputs.

variable "vpc_id" {
  description = "ID of the VPC from the VPC module"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs (public or private) to be used by the EKS cluster"
  type        = list(string)
}

# This value is set manually as the Kubernetes version to deploy.
variable "k8s_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"  # You can update this as needed.
}

variable worker_security_group_id {
  description = "worker node sg id defined in root main"
  type = string
}