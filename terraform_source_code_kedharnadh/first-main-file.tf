provider "aws" {

  region     = "ap-south-1"
}

resource "aws_key_pair" "terraform_ec2_key" {
  key_name   = "terraform_ec2_key"
  public_key = "${file("terraform_ec2_key.pub")}"
}

resource "aws_instance" "ourfirst" {
  ami           = "ami-00bb6a80f01f03502"
  instance_type = "t2.micro"
  key_name = "terraform_ec2_key"
  security_groups = ["${aws_security_group.example.name}"]

  tags = {
    Name = "India-server"
  }
    user_data = <<-EOF
#!/bin/bash
sudo apt update -y 
sudo apt install apache2 -y 
sudo apt install zip -y
sudo systemctl start apache2
sudo systemctl enable apache2 
cd /var/www/html/
sudo rm index.html
sudo wget https://www.free-css.com/assets/files/free-css-templates/download/page296/oxer.zip
sudo unzip oxer.zip
cd oxer-html
sudo cp -r * /var/www/html/
EOF

  }


resource "aws_security_group" "example" {
  name   = "security-group"
 ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  
  }
   ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
}



//resource "aws_instance" "ourfirst" {
 // ami           = "ami-0447a12f28fddb066"
  //instance_type = "t2.micro"
//}
