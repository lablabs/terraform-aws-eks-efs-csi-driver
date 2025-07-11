/**
 * # AWS EKS EFS CSI driver Terraform module
 *
 * A terraform module to deploy the [AWS EFS CSI driver](https://github.com/kubernetes-sigs/aws-efs-csi-driver/) on Amazon EKS cluster.
 *
 * [![Terraform validate](https://github.com/lablabs/terraform-aws-eks-efs-csi-driver/actions/workflows/validate.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-efs-csi-driver/actions/workflows/validate.yaml)
 * [![pre-commit](https://github.com/lablabs/terraform-aws-eks-efs-csi-driver/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-efs-csi-driver/actions/workflows/pre-commit.yaml)
 */

locals {
  addon = {
    name      = "efs-csi-driver"
    namespace = "kube-system"

    helm_chart_name    = "aws-efs-csi-driver"
    helm_chart_version = "3.1.5"
    helm_repo_url      = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  }

  addon_irsa = {
    (local.addon.name) = {
      irsa_policy_enabled = local.irsa_policy_enabled
      irsa_policy         = var.irsa_policy != null ? var.irsa_policy : try(data.aws_iam_policy_document.this[0].json, "")
    }
  }

  addon_values = yamlencode({
    controller = {
      serviceAccount = {
        create = module.addon-irsa[local.addon.name].service_account_create
        name   = module.addon-irsa[local.addon.name].service_account_name
        annotations = module.addon-irsa[local.addon.name].irsa_role_enabled ? {
          "eks.amazonaws.com/role-arn" = module.addon-irsa[local.addon.name].iam_role_attributes.arn
        } : tomap({})
      }
    }
    node = {
      serviceAccount = {
        create = false
        name   = module.addon-irsa[local.addon.name].service_account_name
      }
    }
  })

  addon_depends_on = []
}
