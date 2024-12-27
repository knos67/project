# 1. 환경변수
env = {
    name = "stage"
    region = "ap-southeast-1"
    pf = "io-stage"
}

## 2. 네트워크 변수

### 2.1 VPC
vpc = {
    name              = "vpc"
    cidr_block        = "10.2.0.0/16"
    tenancy           = "default"
    enable_dns_name = true
    tags = {
        Name    = "-vpc"
    }
}

### 2.2 Subnets
# map의 키 값을 pub-1 따위로 주는건 자원 생성이 속성 참조할 때를 대비
# 현 프로젝트에 맞는 값을 준다면 추후에 모듈 재활용할 때마다 수정해야한다.
# 예를 들어, nat gw 배치하는 서브넷을 매 프로젝트 바꿀게 아니라면, pub1으로도 충분
subnets = {
  "pub-1" = {
    #name              = "-snet-pub-1"
    cidr_block        = "10.2.0.0/24"
    availability_zone = "ap-southeast-1a"
    map_public_ip     = true
    type = "public"
    tags = {
      Name    = "-snet-pub-1"
      Type    = "public"
    }
  }
  "priv-1" = {
    #name              = "-snet-priv-1"
    cidr_block        = "10.2.1.0/24"
    availability_zone = "ap-southeast-1a"
    map_public_ip     = false
    type = "private"
    tags = {
      Name    = "-snet-priv-1"
      Type    = "private"
    }
  }
}

### 2.3 IGW
igw = {
    name = "-igw"
    tags = {
        Name    = "-igw"
    }
}

### 2.4 NGW
natgw = {
    name = "-natgw"
    tags = {
        Name    = "-natgw"
    }
}

### 2.5 RTB Public
# rtb-pub = {
#     "rtb-pub" = {
#         route = {
#             cidr_block = "0.0.0.0/0"
#         }
#         tags = {
#             Name    = "-rtb-pub"
#             Service = "${local.env}"
#         }
#     }
# }
rtb_pub = {
    route = {
        cidr_block = "0.0.0.0/0"
    }
    tags = {
        Name    = "-rtb-pub"
    }
}

### 2.6 RTB Private
# rtb-priv ={
#     "rtb-priv" = {
#         route = {
#             cidr_block = "0.0.0.0/0"
#         }
#         tags = {
#             Name    = "-rtb-priv"
#             Service = "${local.env}"
#         }
#     }
# }
rtb_priv = {
    route = {
        cidr_block = "0.0.0.0/0"
    }
    tags = {
        Name    = "-rtb-priv"
    }
}

# ### 2.7 RTB Association (with Subnets) - Public
# # 이름만 준다. 태그도 안붙음
# rtb-assoc-pub = "rtb-assoc-pub"

# ### 2.8 RTB Association (with Subnets) - Private
# # 이름만 준다. 태그도 안붙음
# rtb-assoc-priv = "rtb-assoc-priv"

### 2.9.1 VPC Endpoints(VPCE) - Gateway
vpce-gw = {
    "vpce-SQS" = {
        name = "vpce-SQS"
        tags = {
            Name    = "-vpce-SQS"
        }
    }
}


### 2.9.2 VPC Endpoints(VPCE) - Interface
vpce-if = {
    "vpce-S3" = {
        name = "vpce-S3"
        vpc_endpoint_type = "Interface"
        private_dns_enabled = true
        tags = {
            Name    = "-vpce-S3"
        }
    }
}

### 2.10 EIPs

eips = {
    "bastion" = {
        tags = {
            Name    = "-eip-bastion"
        }
    }
    "NGW" = {
        tags = {
            Name    = "-eip-NGW"
        }
    }
    # "ovpn" = {
    #     tags = {
    #         Name    = "-eip-ovpn"
    #     }
    # }
}