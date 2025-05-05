provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "test_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terraform_vpc"
  }
}

resource "aws_subnet" "test_subnet" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "10.0.0.0/22" 
  tags = {
    Name = "terraform_subnet"
  }
}

resource "aws_security_group" "test_sg" {
  name = "securitygroup2"
  description = "Allow http and ssh ports"
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "terrafrom_securitygroup"
  }
  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {  #allowing http port
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #from anywhere
    }

    egress{
    from_port = 0
    to_port = 0
    protocol = "-1" #  any port
    cidr_blocks = ["0.0.0.0/0"] # anywhere
  }
}

resource "aws_key_pair" "test_key_pair" {
  key_name = "Testing_Key_pair2"
  public_key = "${file("terraform_key_pair.pub")}"
  tags = {
    Name = "terraform_key_pair"
  }
}

resource "aws_instance" "test1" {
  ami           = "ami-00bb6a80f01f03502"
  instance_type = "t2.micro"
  key_name = "Testing_Key_pair2"
  subnet_id = aws_subnet.test_subnet.id
  security_groups = [aws_security_group.test_sg.id]
  tags = {
    Name = "Terraform-Instance"  #this will be name of the ec2 instance
  }
  
}
