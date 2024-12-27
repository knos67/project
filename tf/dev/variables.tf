# 여기서 선언한 변수는 var.VARNAME으로 사용 가능하다.
# 실제 값을 넣지는 않고 선언만 해준다.

## Environment Information

# 환경값
variable "env" {
    type = string
}

# 자원명 접두사
variable "pf" {
    type = string
}

variable "vpc" {
    type  = object({
        name = string
        tenancy = string
        enable-dns-name = bool
    })
}

#variable "subnets"
