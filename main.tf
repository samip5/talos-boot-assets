provider "aws" {
  region = "eu-north-1"
}

module "vpc" {
  source = "./modules/vpc"
}

module "iam" {
  source = "./modules/iam"
}

module "s3" {
  source            = "./modules/s3"
  bucket_name       = "com.github.samip5.buildkit"
  ec2_instance_role = module.iam.iam_role_name
  vpc_id            = module.vpc.vpc_id
}

module "ec2-sg" {
  source = "./modules/ec2-sg"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source                  = "./modules/ec2"
  iam_instance_profile    = module.iam.iam_instance_profile
  route_table_association = module.vpc.route_table_association
  security_group_id       = module.ec2-sg.security_group_id
  subnet_ids              = module.vpc.subnet_ids
  ts_auth_key             = var.ts_auth_key
}

output "instance_amd64_id" {
  value = module.ec2.instance_amd64_id
}

output "instance_arm64_id" {
  value = module.ec2.instance_arm64_id
}
