output "out_vpc_id" {
    value = aws_vpc.vpc.id
}

output "out_subnet_ids" {
    value = aws_subnet.subnets
}

output "out_eips" {
    value = aws_eip.eips
}