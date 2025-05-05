variable "cluster_name" {
    description = "This is the name of the EKS cluster which will be created"
  
}

variable "subnet_ids" {
  description = "Subnets which we need to consider for Cluster for HA"
}

#variable "cluster_role_arn" {
 # description = "This the role which we defined"
#}
