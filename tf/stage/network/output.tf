output "out_vpc_id" {
    value = aws_vpc.vpc.id
}

output "out_subnet_ids" {
    value = { for key, value in aws_subnet.subnets : key => value.id }
}

output "out_eips" {
    value = { for key, value in aws_eip.eips : key => value.public_ip }
}