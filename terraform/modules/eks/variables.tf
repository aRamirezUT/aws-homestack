variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
  default     = "sandbox-cluster"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID associated with your cluster"
}
variable "subnet_ids" {
    type        = list(string)
    description = "A list of subnet IDs for the EKS cluster"
}

variable "control_plane_subnet_ids" {
    type        = list(string)
    description = "A list of subnet IDs for the EKS control plane"
}

variable "disk_size" {
    type        = number
    default     = 20
}

variable "instance_types" {
    type        = list(string)
    description = "A list of instance types for the EKS cluster"
    default     = ["t3.medium"]
}

variable "ami_type" {
    type        = string
    description = "The AMI type for the EKS managed node group"
    default     = "AL2023_x86_64_STANDARD"
}

variable "node_min_size" {
    type        = number
    description = "The minimum size of the EKS managed node group"
    default     = 2
}

variable "node_max_size" {
    type        = number
    description = "The maximum size of the EKS managed node group"
    default     = 10
}
variable "node_desired_size" {
    type        = number
    description = "The desired size of the EKS managed node group"
    default     = 2
}