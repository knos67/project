# VPC 생성시 서브넷, IGW, NATGW 등 생성해주어야 한다.
locals {
    tags = {
        Name = "${var.env.pf}"
        Service = "${var.env.name}"
    }
}
# 1. VPC
resource "aws_vpc" "vpc" {
    cidr_block           = var.vpc.cidr_block
    instance_tenancy     = var.vpc.tenancy # "dedicated" 선택시 내 전용 하드웨어를 배정. 비싸다.
    enable_dns_hostnames = var.vpc.enable_dns_name #생성된 ec2에 대해 dns 주소를 하나씩 준다
    tags = merge(
        local.tags,
        {
        Name = "${local.tags.Name}${var.vpc.tags.Name}"
        }
    )
}

# 2. Subnets
resource "aws_subnet" "subnets" {
    for_each = var.subnets

    vpc_id                  = aws_vpc.vpc.id # attribute reference 
    cidr_block              = each.value.cidr_block
    availability_zone       = each.value.availability_zone
    map_public_ip_on_launch = each.value.map_public_ip

    tags = merge(
    local.tags,
    {
    Name = "${local.tags.Name}${each.value.tags.Name}"
    Type = "${each.value.tags.Type}"
    }
)
}

# 3. IGW
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id # attribute reference
    tags = merge(
        local.tags,
        {
            Name = "${local.tags.Name}${var.igw.tags.Name}"
        }
    )
}


# 4. Nat GW
resource "aws_nat_gateway" "natgw" {
    subnet_id     = aws_subnet.subnets["pub-1"].id # 퍼블릿 서브넷으로 가야한다.
    allocation_id = aws_eip.eips["NGW"].id # 생성한 EIP를 할당한다.
    tags = merge(
        local.tags,
        {
            Name = "${local.tags.Name}${var.natgw.tags.Name}"
        }
    )
}

# 5. Rtb - public
# resource "aws_route_table" "rtb_pub" {
#     for_each = var.rtb-pub

#     vpc_id = aws_vpc.vpc.id
#     route {
#         cidr_block = each.value.route.cidr_block
#         gateway_id = aws_internet_gateway.igw.id
#     }
#     tags = each.value.tags
# }
resource "aws_route_table" "rtb_pub" {
    vpc_id = aws_vpc.vpc.id # attribute reference
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id # attribute reference
    }
    tags = merge(
        local.tags,
        {
            Name = "${local.tags.Name}${var.rtb_pub.tags.Name}"
        }
    )
}

# 6. Rtb - private
# resource "aws_route_table" "rtb_priv" {
#     # for_each = var.rtb-priv

#     vpc_id = aws_vpc.vpc.id
#     route {
#         cidr_block = each.value.route.cidr_block
#         gateway_id = aws_nat_gateway.natgw.id
#     }
#     tags = each.value.tags
# }
resource "aws_route_table" "rtb_priv" {
    vpc_id = aws_vpc.vpc.id # attribute reference
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.natgw.id # attribute reference
    }
    tags = merge(
        local.tags,
        {
            Name = "${local.tags.Name}${var.rtb_priv.tags.Name}"
        }
    )
}

# Associate rtb with subnets

# with public subnets
resource "aws_route_table_association" "rtb_assoc_pub" {
    # type = public만 선택 후 연결
    # for_each를 통해 생성한 서브넷은 모든 속성을 출력하지 않는다. 따라서 var.subnets을 통해 참조
    for_each = { for idx, subnet in aws_subnet.subnets : idx => subnet if subnet.tags_all.Type == "public"}
    
    subnet_id      = each.value.id
    route_table_id = aws_route_table.rtb_pub.id
}

resource "aws_route_table_association" "rtb_assoc_priv" {
    # type = public만 선택 후 연결
    for_each = { for idx, subnet in aws_subnet.subnets : idx => subnet if subnet.tags_all.Type == "private"}
    
    subnet_id      = each.value.id
    route_table_id = aws_route_table.rtb_priv.id
}

resource "aws_eip" "eips" {
    for_each = var.eips
    tags = merge(
        local.tags,
        {
            Name = "${local.tags.Name}${each.value.tags.Name}"
        }
    )
}