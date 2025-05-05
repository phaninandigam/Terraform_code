resource "aws_eks_node_group" "Phani-nodegroup" {
    cluster_name = var.cluster_name
    node_group_name = var.node_groupname
    node_role_arn = data.aws_iam_role.pull_ami1.arn
    subnet_ids      = var.subnet_ids
    disk_size = "20"
    scaling_config {
      desired_size = var.desired_size
      max_size = var.maxvalue
      min_size = var.minvalue
    }
    instance_types = [var.instance_type]
    ami_type       = "AL2_x86_64"
    
    #depends_on = [ aws_eks_cluster.Phani_EKS_Cluster ]
}

data "aws_iam_role" "pull_ami1" {
  name = "Phani_EKS_Nodegroup"
}

output "role_arn1" {
  value = data.aws_iam_role.pull_ami1.arn
}