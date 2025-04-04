variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "OIDC Issuer URL of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "oidc_provider_arn"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  type        = string
}
