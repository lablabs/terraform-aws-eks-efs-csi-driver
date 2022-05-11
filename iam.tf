locals {
  irsa_role_create = var.enabled && var.service_account_create && var.irsa_role_create

}

data "aws_iam_policy_document" "this" {
  count = local.irsa_role_create && var.irsa_policy_enabled ? 1 : 0

  statement {
    actions = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets",
      "ec2:DescribeAvailabilityZones"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "elasticfilesystem:CreateAccessPoint"
    ]
    resources = ["*"]
    #checkov:skip=CKV_AWS_111 there is correct condition for existing Tags
    # Official documentation https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/v1.3.7/docs/iam-policy-example.json
    effect = "Allow"
    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    actions = [
      "elasticfilesystem:DeleteAccessPoint"
    ]
    resources = ["*"]
    effect    = "Allow"
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
}

resource "aws_iam_policy" "this" {
  count       = local.irsa_role_create && var.irsa_policy_enabled ? 1 : 0
  name        = "${var.irsa_role_name_prefix}-${var.helm_release_name}"
  path        = "/"
  description = "Policy for the EFS CSI driver"

  policy = data.aws_iam_policy_document.this[0].json
  tags   = var.irsa_tags
}

data "aws_iam_policy_document" "this_assume" {
  count = local.irsa_role_create ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.cluster_identity_oidc_issuer_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_identity_oidc_issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${var.namespace}:${var.service_account_name}",
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "this" {
  count = local.irsa_role_create ? 1 : 0

  name               = "${var.irsa_role_name_prefix}-${var.helm_release_name}"
  assume_role_policy = data.aws_iam_policy_document.this_assume[0].json

  tags = var.irsa_tags
}

resource "aws_iam_role_policy_attachment" "this" {
  count = local.irsa_role_create ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}
