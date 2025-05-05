provider "aws" {
  region = var.kedhar
}

variable "kedhar" {
 default = "ap-south-2"
 description = "The default region"
}

terraform {
  backend "s3" {
    region = "ap-south-1"
    bucket = "kedhar-workspace"
    key = "state.tfstate"
    encrypt = true
    dynamodb_table = "tf-lock"
  }
}

locals {

  env="${terraform.workspace}"

  counts = {
    "default"=1
    "prod"=3
    "dev"=2
    "staging"=4
  }

  instances = {
    "default"="t2.micro"
    "prod"="t3.medium"
    "dev"="t2.micro"
    "staging"="t3.small"
  }

  tags = {

    "default"="webserver-def"
    "prod"="webserver-prod"
    "dev"="webserver-dev"
    "staging"="webserver-stag"
  }


  instance_type="${lookup(local.instances,local.env)}"
  count="${lookup(local.counts,local.env)}"
  mytag="${lookup(local.tags,local.env)}"
 
}


resource "aws_instance" "my_work" {
 ami="ami-0447a12f28fddb066"
 instance_type="${local.instance_type}"
 count="${local.count}"
 tags = {
    Name="${local.mytag}"
 }

}
