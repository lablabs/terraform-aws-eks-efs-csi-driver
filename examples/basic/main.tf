module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.13.0"

  name               = "efs_csi_controller-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["eu-central-1a", "eu-central-1b"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
}

module "eks_cluster" {
  source  = "cloudposse/eks-cluster/aws"
  version = "0.45.0"

  region     = "eu-central-1"
  subnet_ids = module.vpc.public_subnets
  vpc_id     = module.vpc.vpc_id
  name       = "efs_csi_controller"
}

module "eks_node_group" {
  source  = "cloudposse/eks-node-group/aws"
  version = "0.28.0"

  cluster_name   = "efs_csi_controller"
  instance_types = ["t3.medium"]
  subnet_ids     = module.vpc.public_subnets
  min_size       = 1
  desired_size   = 1
  max_size       = 2
  depends_on     = [module.eks_cluster.kubernetes_config_map_id]
}

module "efs_csi_disabled" {
  source = "../../"

  enabled = false

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
}

module "efs_csi_helm" {
  source = "../../"

  enabled           = true
  argo_enabled      = false
  argo_helm_enabled = false

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn

  helm_release_name = "aws-efs-csi-helm"
  namespace         = "aws-efs-csi-helm"

  values = yamlencode({
    "podLabels" : {
      "app" : "aws-efs-csi-helm"
    }
  })

  helm_timeout = 240
  helm_wait    = true
}

module "efs_csi_argo_kubernetes" {
  source = "../../"

  enabled           = true
  argo_enabled      = true
  argo_helm_enabled = false

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn

  helm_release_name = "aws-efs-csi-argo-kubernetes"
  namespace         = "aws-efs-csi-argo-kubernetes"

  argo_sync_policy = {
    "automated" : {}
    "syncOptions" = ["CreateNamespace=true"]
  }
}

module "efs_csi_argo_helm" {
  source = "../../"

  enabled           = true
  argo_enabled      = true
  argo_helm_enabled = true

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn

  helm_release_name = "aws-efs-csi-argo-helm"
  namespace         = "aws-efs-csi-argo-helm"

  argo_namespace = "argo"
  argo_sync_policy = {
    "automated" : {}
    "syncOptions" = ["CreateNamespace=true"]
  }
}
