resource "aws_eks_cluster" "Phani-cluster" {
    name = var.cluster_name
    role_arn = data.aws_iam_role.pull_role.arn

    vpc_config {
      subnet_ids = var.subnet_ids
    }

    }

output "cluster_name" {
  value = aws_eks_cluster.Phani-cluster.name
}
  
data "aws_iam_role" "pull_role" {
    name = "Phani_EKS_Cluster"
  }

output "role_arn" {
  value = data.aws_iam_role.pull_role.arn
}
