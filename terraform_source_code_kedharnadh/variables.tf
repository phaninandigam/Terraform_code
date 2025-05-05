variable "default_region" {
  default = "ap-south-1"
  description = "The default region"
}

variable "availability_zone" {
  default = "ap-south-1a"
}
variable "vpc_block" {
  default = "10.0.0.0/16"
  description = "CIDR block"
}

variable "vpc_name" {
  default = "default_VPC"
  description = "Name of the VPC"
}

variable "subnet_block" {
  default = "10.0.0.0/18"
  description = "CIDR block of the subnet"
}

variable "subnet_name" {
  default = "default_VPC"
  description = "Name of the VPC"
}

variable "security_groups_group_name" {
  default = "launch-wizard-1"
  description = "security group name"
}

variable "security_groups_desc" {
  default = "Allow http and ssh ports"
  description = "security group name description"
}

variable "security_groups_name" {
  default = ""
  description = "security group name"
}

variable "ssh_port" {
  default = "22"
  description = "SSH port"
}

variable "http_port" {
  default = "80"
  description = "HTTP port"
}

variable "protocol" {
  default = "tcp"
  description = "tcp protocol"
}

variable "to_from_port" {
  default = "0"
}

variable "any_protocol" {
  default = "-1"
  description = "tcp protocol"
}

variable "traffic_from_anywhere" {
  default = ["0.0.0.0/0"]
  description = "Allow traffic from anywhere"
}

variable "key_name" {
  default = "Key-pair-1"
  description = "Key name"
}
variable "key_pair_name" {
  default = "key-pair-tag"
  description = "Key pair name"
}

variable "ami_id" {
  default = "ami-00bb6a80f01f03502"
  description = "AMI id"
}

variable "instance_type" {
  default = "t2.micro"
  description = "The EC2 instance type"
}

variable "instance_name" {
  default = "India-Server-1"
  description = "Name of the instance"
}