env = "dev"
pf = "io-dev-" # 만약을 위한 용도.
vpc = {
    name              = "${local.pf}vpc"
    cidr_block        = "1.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip     = true
}