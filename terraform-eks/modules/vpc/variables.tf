// Variables for the VPC module. All values are assigned default values so no external inputs are required.

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "public_azs" {
  description = "List of availability zones for public subnets"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "private_azs" {
  description = "List of availability zones for private subnets"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}
