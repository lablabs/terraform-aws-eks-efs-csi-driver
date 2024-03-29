# Basic example

The code in this example shows how to use the module with basic configuration and minimal set of other resources.

## Deployment methods

### Helm

Deploy helm chart by helm (default method, set `enabled = true`)

### Argo kubernetes

Deploy helm chart as argo application by kubernetes manifest (set `enabled = true` and `argo_enabled = true`)

### Argo helm

Create helm release resource and deploy it as argo application (set `enabled = true`, `argo_enabled = true` and `argo_helm_enabled = true`)

## AWS IAM resources

To disable of creation IRSA role and IRSA policy, set `irsa_role_create = false` and `irsa_policy_enabled = false`, respectively

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.19.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.6.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.11.0 |
| <a name="requirement_utils"></a> [utils](#requirement\_utils) | >= 0.17.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_efs_csi_argo_helm"></a> [efs\_csi\_argo\_helm](#module\_efs\_csi\_argo\_helm) | ../../ | n/a |
| <a name="module_efs_csi_argo_kubernetes"></a> [efs\_csi\_argo\_kubernetes](#module\_efs\_csi\_argo\_kubernetes) | ../../ | n/a |
| <a name="module_efs_csi_disabled"></a> [efs\_csi\_disabled](#module\_efs\_csi\_disabled) | ../../ | n/a |
| <a name="module_efs_csi_helm"></a> [efs\_csi\_helm](#module\_efs\_csi\_helm) | ../../ | n/a |
| <a name="module_eks_cluster"></a> [eks\_cluster](#module\_eks\_cluster) | cloudposse/eks-cluster/aws | 0.45.0 |
| <a name="module_eks_node_group"></a> [eks\_node\_group](#module\_eks\_node\_group) | cloudposse/eks-node-group/aws | 0.28.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.13.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
