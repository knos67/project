# 다른 모듈에서 참조하는 변수들을 모두 여기서 출력한다.
# value는 vpc 모듈이 생성한 객체에서 가져오고, 
# output 변수명은 module.vpc.변수명 형태로 사용해 value를 가져갈 수 있다.

# output "public_subnet1_id" {
#     value = aws_subnet.public_subnet1.id
# }

# output "public_subnet2_id" {
#     value = aws_subnet.public_subnet2.id
# }

# output "private_subnet1_id" {
#     value = aws_subnet.private_subnet1.id
# }

# output "private_subnet2_id" {
#     value = aws_subnet.private_subnet2.id
# }

output "vpc-id" {
    value = aws_vpc.vpc.id
}