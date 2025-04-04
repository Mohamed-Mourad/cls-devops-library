# AWS Load Balancer Controller setup using IRSA
module "eks_aws_load_balancer_controller" {
  source  = "akw-devsecops/eks/aws//modules/aws-load-balancer-controller"
  version = "4.1.0"

  oidc_provider_arn = var.oidc_provider_arn
}
