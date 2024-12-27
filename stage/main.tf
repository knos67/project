terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.77.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-southeast-1"
}

# [공통]
# service_type: prod | test
# vpc_id, subnet_ids 는 더 이상 사용자 입력 변수가 아니다
# vpc 모듈에서 나오는 값을 사용

#모듈 선언

# ALB
module "cicd" {
    # 모듈 경로
    source = "./alb"

    # 네트워크 공통
    service_type = var.service_type

    # Output Forwarding (by Parent Module)
    vpc_id = module.vpc.vpc_id

    # 모듈 파라미터

    # 아래 두 서브넷 이름 필드는 임의로 만든거다. 자의적 이름의 변수.
    
    # Output Forwarding (by Parent Module)
    subnet_ids = [module.vpc.public_subnet1_id, module.vpc.public_subnet2_id]

    # depends_on 통해 모듈 생성의 순서를 정한다.
    # docker-compose와 유사
    depends_on = [module.ec2]
}

module "community" {
    # 모듈 경로
    source = "./ec2"

    # 네트워크 공통
    service_type = var.service_type

    # Output Forwarding (by Parent Module)
    vpc_id = module.vpc.vpc_id

    # 모듈 파라미터 (변수다 변수. 맘대로 이름 정하고 안에서 제대로 할당만 하면 됨.)
    instance_type  = "t2.micro"
    user_data_path = "./ec2/userdata.sh"

    # Output Forwarding (by Parent Module)
    private_subnet1_id = module.vpc.private_subnet1_id

    # 기타 aws_instance 관련 파라미터들 여기에 기입

}

module "data" {
    # 모듈 경로
    source = "./ec2-bastion"

    # 네트워크 공통
    service_type = var.service_type

    # Output Forwarding (by Parent Module)
    vpc_id = module.vpc.vpc_id

    # 모듈 파라미터
      instance_type  = "t2.micro"
    # user_data_path = "./ec2/userdata.sh"

    # Output Forwarding (by Parent Module)
    public_subnet1_id = module.vpc.public_subnet1_id

    # 기타 aws_instance 관련 파라미터들 여기에 기입
}

module "monitoring" {
    # 모듈 경로
    source = "./rds"

    # 네트워크 공통
    service_type = var.service_type
    vpc_id       = module.vpc.vpc_id

    # 모듈 파라미터
    instance_class      = "db.t4g.micro"
    username            = "admin"
    password            = "13243546"
    publicly_accessible = false

    # Output Forwarding (by Parent Module)
    private_subnet1_id = module.vpc.private_subnet1_id
    private_subnet2_id = module.vpc.private_subnet2_id
}

module "noti" {
    # 모듈 경로
    source = "./s3"

    # 네트워크 공통
    service_type = var.service_type

    # Output Forwarding (by Parent Module)
    vpc_id = module.vpc.vpc_id

    # 모듈 파라미터

    # 변수와 문자열 결합에서는 ${VARNAME} 사용
    bucket = "saju-front-${var.service_type}-08"
}

module "network" {
    # 모듈 경로
    source = "./vpc"

    # 모듈 파라미터
    service_type = var.service_type
}

module "misc" {
    # 모듈 경로
    source = "./vpc"

    # 모듈 파라미터
    service_type = var.service_type
}