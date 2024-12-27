# # EC2(api server) - Private IP for bastion access
# output "private_ip" {
#     value = module.ec2.private_ip
# }

# # EC2(bastion) - EIP: // ec2-bastion 모듈에 output에 선언한 eip_ip
# output "eip_ip" {
#     value = module.ec2-bastion.eip_ip
# }

# # RDS - endppoint
# output "rds_endpoint" {
#     value = module.rds.rds_endpoint
# }

# # S3 - endpoint
# output "s3_endpoint" {
#     value = module.s3.s3_endpoint
# }

# # ALB - dnsname // aws 객체가 아니라 alb 모듈에서 가져온다
# output "alb_dns_name" {
#     value = module.alb.alb_dns_name
# }