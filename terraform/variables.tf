variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1"
}

variable "name" {
  description = "The name to use for resources"
  type        = string
  default     = "myapp-eks"
}

variable "k8s_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.33" 
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable private_subnet_cidr_blocks {
    default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable public_subnet_cidr_blocks {
    default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable tags {
  default = {
    App  = "eks-devops"
  }
}
