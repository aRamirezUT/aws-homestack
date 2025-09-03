module "vpc"{
  source = "../../modules/network"
}

module "eks" {
  source  = "../../modules/eks"
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnet_ids
  control_plane_subnet_ids = module.vpc.private_subnet_ids

  cluster_name             = var.cluster_name
  instance_types           = var.instance_types
  ami_type                 = var.ami_type
  node_min_size            = var.node_min_size
  node_max_size            = var.node_max_size
  node_desired_size        = var.node_desired_size
}