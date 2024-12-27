# 1. 환경변수
env = {
    name = "stage"
    region = "ap-southeast-1"
    pf = "io-stage"
}

## 2. 네트워크 변수

### 2.1 VPC
vpc = {
    name              = "${local.pf}-vpc"
    cidr_block        = "10.2.0/16"
    tenancy           = "default"
    enable_dns_support = true
    tags = {
        Name    = "${local.pf}-vpc"
        Service = "${local.env}"
    }
}

### 2.2 Subnets
subnets = {
  "${local.pf}-snet-pub-1" = {
    #name              = "${local.pf}-snet-pub-1"
    cidr_block        = "10.2.0.0/24"
    availability_zone = "${local.region}"
    map_public_ip     = true
    tags = {
      Name    = "${local.pf}-snet-pub-1"
      Service = "${local.env}"
    }
  }
  "${local.pf}-snet-priv-1" = {
    #name              = "${local.pf}-snet-priv-1"
    cidr_block        = "10.2.1.0/24"
    availability_zone = "${local.region}"
    map_public_ip     = false
    tags = {
      Name    = "${local.pf}-snet-priv-1"
      Service = "${local.env}"
    }
  }
}

### 2.3 IGW
igw = {
    name = "${local.pf}-igw"
    tags = {
        Name    = "${local.pf}-igw"
        Service = "${local.env}"
    }
}

### 2.4 NGW
natgw = {
    name = "${local.pf}-natgw"
    tags = {
        Name    = "${local.pf}-natgw"
        Service = "${local.env}"
    }
}

### 2.5 RTB Public
rtb-pub = {
    "${local.pf}-rtb-pub" = {
        route = {
            cidr_block = "0.0.0.0/0"
        }
        tags = {
            Name    = "${local.pf}-rtb-pub"
            Service = "${local.env}"
        }
    }
}

### 2.6 RTB Private
rtb-priv ={
    "${local.pf}-rtb-priv" = {
        route = {
            cidr_block = "0.0.0.0/0"
        }
        tags = {
            Name    = "${local.pf}-rtb-priv"
            Service = "${local.env}"
        }
    }
}

### 2.7 RTB Association (with Subnets) - Public
# 이름만 준다. 태그도 안붙음
rtb-assoc-pub = "rtb-assoc-pub"

### 2.8 RTB Association (with Subnets) - Private
# 이름만 준다. 태그도 안붙음
rtb-assoc-priv = "rtb-assoc-priv"

### 2.9.1 VPC Endpoints(VPCE) - Gateway
vpce-gw = {
    "${local.pf}-vpce-SQS" = {
        name = "${local.pf}-vpce-SQS"
        tags = {
            Name    = "${local.pf}-vpce-SQS"
            Service = "${local.env}"
        }
    }
}


### 2.9.2 VPC Endpoints(VPCE) - Interface
vpce-if = {
    "${local.pf}-vpce-S3" = {
        name = "${local.pf}-vpce-S3"
        vpce_endpoint_type = "Interface"
        private_dns_enabled = true
        tags = {
            Name    = "${local.pf}-vpce-S3"
            Service = "${local.env}"
        }
    }
}

### 2.10 EIPs

eips = {
    "${local.pf}-eip-bastion" = {
        tags = {
            Name    = "${local.pf}-eip-bastion"
            Service = "${local.env}"
        }
    }
    "${local.pf}-eip-NGW" = {
        tags = {
            Name    = "${local.pf}-eip-NGW"
            Service = "${local.env}"
        }
    }
    "${local.pf}-eip-ovpn" = {
        tags = {
            Name    = "${local.pf}-eip-ovpn"
            Service = "${local.env}"
        }
    }
}