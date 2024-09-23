
locals {
  #calculate the number of availability zones
  azs = length(data.aws_availability_zones.available.names)
}

//calling the network module

module "network" {
  source   = "./_modules/network"
  azs      = local.azs
  vpc_name = var.vpc_name
  tags     = merge(var.tags,{
    "ext-tag"= terraform.workspace
  })
  cidrvpc  = var.cidrvpc
  aznames  = data.aws_availability_zones.available.names
}

//calling the ec2 module
module "ec2" {
  source     = "./_modules/ec2"
  depends_on = [module.network]
  for_each = var.bastion_definition
  bastion_instance_class = each.value.bastion_instance_class
  bastion_name           = each.value.bastion_name
  bastion_public_key     = each.value.bastion_public_key
  trusted_ips            = toset(each.value.trusted_ips)
  default_tags           = merge(var.tags, each.value.ext-tags)
  user_data_base64       = each.value.user_data_base64
  bastion_ami            = each.value.bastion_ami
  associate_public_ip_address = each.value.associate_public_ip_address
  public_subnet_id       = module.network.public_subnet_id[0]
  bastion_monitoring     = each.value.bastion_monitoring
  vpc_id                 = module.network.vpc_id
} 

# module "s3" {
#   count = var.create_s3_bucket ? 1 : 0
#   source = "./_modules/s3"
# }
