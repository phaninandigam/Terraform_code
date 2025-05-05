provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "k8s_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                              = "K8s-cluster-vpc"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

# Subnet
resource "aws_subnet" "k8s_subnet" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "K8s-cluster-net"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name = "K8s-cluster-igw"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

# Route Table
resource "aws_route_table" "k8s_route_table" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name = "K8s-cluster-rtb"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.k8s_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.k8s_igw.id
}

resource "aws_route_table_association" "k8s_rta" {
  subnet_id      = aws_subnet.k8s_subnet.id
  route_table_id = aws_route_table.k8s_route_table.id
}

# IAM Role for Master Node
resource "aws_iam_role" "k8s_master_role" {
  name = "k8s-cluster-iam-master-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "k8s-master-role"
  }
}

# IAM Policy for Master Node (read from your JSON file)
resource "aws_iam_policy" "k8s_master_policy" {
  name        = "k8s-cluster-iam-master-policy"
  description = "IAM Policy for Kubernetes Master Node"

  policy = file("${path.module}/policies/k8s-master-policy.json")
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach_master_policy" {
  role       = aws_iam_role.k8s_master_role.name
  policy_arn = aws_iam_policy.k8s_master_policy.arn
}

# IAM Role for Worker Node
resource "aws_iam_role" "k8s_worker_role" {
  name = "k8s-cluster-iam-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "k8s-worker-role"
  }
}

# IAM Policy for Worker Node (read from your JSON file)
resource "aws_iam_policy" "k8s_worker_policy" {
  name        = "k8s-cluster-iam-worker-policy"
  description = "IAM Policy for Kubernetes Worker Node"

  policy = file("${path.module}/policies/k8s-worker-policy.json")
}

# Attach the policy to the worker role
resource "aws_iam_role_policy_attachment" "attach_worker_policy" {
  role       = aws_iam_role.k8s_worker_role.name
  policy_arn = aws_iam_policy.k8s_worker_policy.arn
}


resource "aws_security_group" "k8s_sg" {
  name        = "k8s-master-sg"
  description = "Security Group for Kubernetes Master Node"
  vpc_id      = aws_vpc.k8s_vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API Server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "etcd server client API"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "kube-scheduler"
    from_port   = 10251
    to_port     = 10251
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "kube-controller-manager"
    from_port   = 10252
    to_port     = 10252
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Read-Only Kubelet API"
    from_port   = 10255
    to_port     = 10255
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Schedular"
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Controller"
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Internal communication within VPC
  ingress {
    description = "VPC Internal"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-master-sg"
  }
}


# Data source to fetch the latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu_22_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM Instance Profile for EC2 Master
resource "aws_iam_instance_profile" "k8s_master_profile" {
  name = "k8s-cluster-iam-master-profile"
  role = aws_iam_role.k8s_master_role.name
}
#Key for ec2
resource "tls_private_key" "k8s_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "k8s_key_pair" {
  key_name   = "k8s-key" # You can give it a better name
  public_key = tls_private_key.k8s_ssh_key.public_key_openssh
}

# EC2 Instance for Master Node
resource "aws_instance" "k8s_master" {
  ami                    = data.aws_ami.ubuntu_22_04.id
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.k8s_subnet.id
  iam_instance_profile   = aws_iam_instance_profile.k8s_master_profile.name
  key_name               = aws_key_pair.k8s_key_pair.key_name #var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  tags = {
    Name = "Master"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

# IAM Instance Profile for EC2 Worker
resource "aws_iam_instance_profile" "k8s_worker_profile" {
  name = "k8s-cluster-iam-worker-profile"
  role = aws_iam_role.k8s_worker_role.name
}

resource "aws_security_group" "k8s_worker_sg" {
  name        = "k8s-worker-sg"
  description = "Security Group for Kubernetes Worker Node"
  vpc_id      = aws_vpc.k8s_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Protocol HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Protocol HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Read-Only Kubelet API"
    from_port   = 10255
    to_port     = 10255
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NodePort Services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "VPC Subnet"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-worker-sg"
  }
}

# EC2 Instance for Worker Node
resource "aws_instance" "k8s_worker" {
  ami                         = data.aws_ami.ubuntu_22_04.id
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.k8s_subnet.id
  iam_instance_profile        = aws_iam_instance_profile.k8s_worker_profile.name
  key_name                    = aws_key_pair.k8s_key_pair.key_name #var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.k8s_worker_sg.id]

  tags = {
    Name = "Worker"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}