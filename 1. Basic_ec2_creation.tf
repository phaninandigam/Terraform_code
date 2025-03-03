resource "aws_instance" "ourfirst" {
  ami           = "ami-00bb6a80f01f03502"
  instance_type = "t2.micro"
}

provider "aws" {
  access_key = "AKIA47"
  secret_key = "R8OwUhVf42"
  region     = "ap-south-1"
}