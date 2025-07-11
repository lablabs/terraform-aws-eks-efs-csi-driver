locals {
  irsa_policy_enabled = var.irsa_policy_enabled != null ? var.irsa_policy_enabled : coalesce(var.irsa_assume_role_enabled, false) == false
}

data "aws_iam_policy_document" "this" {
  count = var.enabled && var.irsa_policy == null && local.irsa_policy_enabled ? 1 : 0

  # Official documentation https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/v2.1.4/docs/iam-policy-example.json
  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets",
      "ec2:DescribeAvailabilityZones"
    ]
    resources = ["*"]
  }

  statement {
    # checkov:skip=CKV_AWS_111 there is correct condition for existing Tags
    effect = "Allow"

    actions = [
      "elasticfilesystem:CreateAccessPoint"
    ]

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    # checkov:skip=CKV_AWS_111 there is correct condition for existing Tags
    effect = "Allow"

    actions = [
      "elasticfilesystem:TagResource"
    ]

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:DeleteAccessPoint"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
}
