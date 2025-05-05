provider "aws" {
  region = "ap-south-1"
}

module "EKS-cluster" {
    source = "./EKS-cluster"
    cluster_name = var.name
    subnet_ids = var.subnet_ids
}

module "EKS-nodegroup"{
    source = "./EKS-nodegroup"
    cluster_name = module.EKS-cluster.cluster_name
    desired_size = "4"
    maxvalue = "20"
    minvalue = "3"
    instance_type = "t3.medium"
    subnet_ids = var.subnet_ids
    depends_on = [ module.EKS-cluster ]
}