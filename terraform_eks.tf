# Define the provider
provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

# Create VPC for the EKS cluster
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"  # Replace with your desired CIDR block

  tags = {
    Name = "eks-vpc"
  }
}

# Create public subnets for the EKS cluster
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.0.0/24"  # Replace with your desired CIDR block
  availability_zone       = "us-east-1a"  # Replace with your desired availability zone

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.1.0/24"  # Replace with your desired CIDR block
  availability_zone       = "us-east-1b"  # Replace with your desired availability zone

  tags = {
    Name = "public-subnet-2"
  }
}
# Create private subnets for the EKS cluster
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.2.0/24"  # Replace with your desired CIDR block
  availability_zone       = "us-east-1a"  # Replace with your desired availability zone

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.3.0/24"  # Replace with your desired CIDR block
  availability_zone       = "us-east-1b"  # Replace with your desired availability zone

  tags = {
    Name = "private-subnet-2"
  }
}

# Create IAM roles for the EKS cluster
resource "aws_iam_role" "eks_worker_role" {
  name = "eks-worker-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
       }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]
}

resource "aws_iam_role" "eks_master_role" {
  name = "eks-master-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]
}
# Create the EKS cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_master_role.arn
  version  = "1.27"  # Replace with a supported Kubernetes version

  vpc_config {
    subnet_ids = [
      aws_subnet.public_subnet_1.id,
      aws_subnet.public_subnet_2.id,
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id,
    ]
  }
}
# Create the launch template for worker nodes
resource "aws_launch_template" "worker_lt" {
  name_prefix   = "eks-worker-lt"
  image_id      = "ami-04823729c75214919"  # Replace with the desired Amazon Linux AMI ID
  instance_type = "t2.medium"     # Replace with your desired instance type

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8  # Replace with your desired root volume size in GB
    }
  }
}
# Create the autoscaling group for worker nodes
resource "aws_autoscaling_group" "worker_asg" {
  name                 = "eks-worker-asg"
  launch_template {
    id      = aws_launch_template.worker_lt.id
    version = "$Latest"
  }
  min_size         = 2  # Replace with your desired minimum number of worker nodes
  max_size         = 5  # Replace with your desired maximum number of worker nodes
  desired_capacity = 2  # Replace with your desired initial number of worker nodes
  vpc_zone_identifier = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
  ]

  tag {
    key                 = "Name"
    value               = "eks-worker"
    propagate_at_launch = true
  }
}
