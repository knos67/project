# VPC

output "out_vpc_id" {
    value = module.network.out_vpc_id
}

output "out_subnet_ids" {
    value = module.network.out_subnet_ids
}

output "out_eips" {
    value = module.network.out_eips
}