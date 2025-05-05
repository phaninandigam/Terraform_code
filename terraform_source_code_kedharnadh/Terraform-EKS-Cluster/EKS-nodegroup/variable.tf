variable "cluster_name" {
  description = "Enter the cluster name"
}

variable "node_groupname" {
    description = "Enter the groupname"
    default = "Phani-node-group"
}

variable "subnet_ids" {
  description = "Enter the Subnet Id's"
}

variable "desired_size" {
    description = "Enter the value whcih you want to create"
  
}

variable "maxvalue" {
  description = "Enter the max instances for auto scaling"
}

variable "minvalue" {
  description = "Enter the min instances which should be maintained"
}

variable "instance_type" {
  description = "Enter the instance type"
}
