# 여기서 선언한 변수는 var.VARNAME으로 사용 가능하다.
# 실제 값을 넣지는 않고 선언만 해준다.

## 1. 환경변수
variable "env" {
    type = object({
        name   = string
        region = string
        pf     = string
        })
}


## 2. 네트워크 변수

### 2.1 VPC
variable "vpc" {
    type  = object({
        name            = string
        cidr_block      = string
        tenancy         = string
        enable-dns-name = bool
        tags            = object({
            Name    = string
            Service = string
        })
    })
}

### 2.2 Subnets
variable "subnets" {
  type = map(object({
    name              = string
    cidr_block        = string
    availability_zone = string
    map_public_ip     = bool
    tags              = object({
      Name    = string
      Service = string
    })
  }))
}

### 2.3 IGW
variable "igw" {
   #vpc_id = aws_vpc.vpc.id
   type    = object({
        name = string
        tags = object({
            Name    = string
            Service = string
        })
    })
}

### 2.4 NGW
variable "natgw" {
# subnet_id     = aws_subnet.public_subnet1.id # 퍼블릿 서브넷으로 가야한다.
# allocation_id = aws_eip.natgw-eip.id # 생성한 EIP를 할당한다.
  type          = object({
        name = string
        tags = object({
            Name    = string
            Service = string
        })
    })
}

### 2.5 RTB Public
variable "rtb-pub" {
    type = map(object({
        #name    = string
        #vpc_id = aws_vpc.vpc.id
        route   = object({
            cidr_block  = string
            #gateway_id = string # IGW reference
        })
        tags = object({
            Name    = string
            Service = string
        })
    }))
}

### 2.6 RTB Private
variable "rtb-priv" {
    type = map(object({
        #name    = string
        #vpc_id = aws_vpc.vpc.id
        route   = object({
            cidr_block  = string
            #gateway_id = string # IGW reference
        })
        tags = object({
            Name    = string
            Service = string
        })
    }))
}

### 2.7 RTB Assoication (with Subnets) - public
variable "rtb-assoc-pub" {
    type = string
}

### 2.8 RTB Assoication (with Subnets) - private
variable "rtb-assoc-priv" {
    type = string

}### 2.9.1 VPC Endpoints(VPCE) - Gateway

variable "vpce-gw" {
    type = map(object({
        name         = string
        # vpc_id       = string
        # service_name = string
        tags         = object({
            Name    = string
            Service = string
        })
    }))
  #vpc_id       = aws_vpc.main.id
  #service_name = "com.amazonaws.us-west-2.s3"
}

### 2.9.2 VPC Endpoints(VPCE) - Interface
variable "vpce-if" {
    type = map(object({
        name         = string
        vpc_endpoint_type = "Interface"
        # vpc_id       = string
        # service_name = string
        private_dns_enabled = true
        tags         = object({
            Name    = string
            Service = string
        })
    }))
  #vpc_id       = aws_vpc.main.id
  #service_name = "com.amazonaws.us-west-2.s3"
}

### 2.10 EIPs
variable "eips" {
    type = map(object({
        # name = string
        tags = object({
            Name    = string
            Service = string
        })
    }))
}