data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

module "network" {
  source = "./modules/network"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "ec2" {
  source = "./modules/ec2"

  project_name    = var.project_name
  ami_id          = var.ami_id != "" ? var.ami_id : data.aws_ssm_parameter.al2023.value
  instance_type   = var.instance_type
  key_name        = var.key_name
  vpc_id          = module.network.vpc_id
  subnet_id       = module.network.public_subnet_ids[0]
  ssh_cidr_blocks = var.ssh_cidr_blocks
}

module "ecr" {
  source = "./modules/ecr"

  # frontend-dev, frontend-stg, frontend-prod, auth-service-dev, ...
  repository_names = [for p in setproduct(var.services, var.environments) : "${p[0]}-${p[1]}"]
}

module "eks" {
  source = "./modules/eks"

  project_name        = var.project_name
  subnet_ids          = module.network.private_subnet_ids
  cluster_version     = var.cluster_version
  public_access_cidrs = var.eks_public_access_cidrs
  node_instance_types = var.node_instance_types
}
