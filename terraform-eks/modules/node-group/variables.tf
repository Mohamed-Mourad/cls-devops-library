// Variables for the Node Group module.
// Values coming from other modules' outputs must be passed in via the environment (e.g., environments/dev/main.tf).

variable "vpc_id" {
  description = "vpc id"
  type = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster (retrieved from the EKS module output)"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the worker nodes will be launched (typically private subnets)"
  type        = list(string)
}

# Manually assigned values for node group configuration
variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "instance_types" {
  description = "List of instance types for the worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "disk_size" {
  description = "Disk size (in GB) for each worker node"
  type        = number
  default     = 20
}

variable "ec2_ssh_key" {
  description = "Name of the EC2 SSH key pair for remote access (if required)"
  type        = string
  default     = "cls-terraform-eks-key"
}

variable "remote_access_security_group_ids" {
  description = "Security group IDs to allow SSH access to the worker nodes"
  type        = list(string)
  default     = []  # If remote access is not required, leave as an empty list.
}

variable "ami_type" {
  description = "AMI type for the EKS node group (e.g., AL2_x86_64 or AL2_x86_64_GPU)"
  type        = string
  default     = "AL2_x86_64"
}

variable "extra_tags" {
  description = "Any additional tags to be applied to the node group"
  type        = map(string)
  default     = {}
}
