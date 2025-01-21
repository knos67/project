provider "aws" {
    region = "ap-southeast-1"
}
#vpc 생성
data "aws_vpc" "main" {
    id = "vpc-02b258dcca45b4936"
}
# 퍼블릭-a
resource "aws_subnet" "main" {
    vpc_id            = data.aws_vpc.main.id
    cidr_block        = "172.31.64.0/24" # 기존 퍼블릭 서브넷 CIDR
    availability_zone = "ap-southeast-1a"
    tags = {
        Name = "IO-public-subnet-a"
    }
}
# 프라이빗-a
resource "aws_subnet" "private_subnet" {
    vpc_id            = data.aws_vpc.main.id
    cidr_block        = "172.31.80.0/24" # 기존 프라이빗 서브넷 CIDR
    availability_zone = "ap-southeast-1a"
    tags = {
        Name = "IO-private-subnet-a"
    }  
}
# 퍼블릭-b
resource "aws_subnet" "main_b" {
    vpc_id            = data.aws_vpc.main.id
    cidr_block        = "172.31.96.0/24" # 기존 퍼블릭 서브넷 CIDR
    availability_zone = "ap-southeast-1b"
    tags = {
        Name = "IO-public-subnet-b"
    }
}
# 프라이빗-b
resource "aws_subnet" "private_subnet_b" {
    vpc_id            = data.aws_vpc.main.id
    cidr_block        = "172.31.112.0/24" # 기존 프라이빗 서브넷 CIDR
    availability_zone = "ap-southeast-1b"  
    tags = {
        Name = "IO-private-subnet-b"
    }  
}

#프라이빗 서브넷을 위한 라우팅 테이블 생성
resource "aws_route_table" "private" {
    vpc_id = data.aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }
    tags = {
      Name = "IO-PrivateRT"
    }
}

#프라이빗 서브넷에 라우팅 테이블 연결
resource "aws_route_table_association" "private_association_a" {
    subnet_id = aws_subnet.private_subnet.id # ap-southeast-1a 프라이빗 서브넷
    route_table_id = aws_route_table.private.id
}
#프라이빗 서브넷에 라우팅 테이블 연결
resource "aws_route_table_association" "private_association_b" {
    subnet_id = aws_subnet.private_subnet_b.id # ap-southeast-1b 프라이빗 서브넷
    route_table_id = aws_route_table.private.id
}
# EIP 생성
resource "aws_eip" "nat_eip" {
    domain = "vpc"

    tags = {
      Name = "Io_EIP"
    }
}

# NAT gateway 생성
resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.main.id
    tags = {
      Name = "IO-nat-gateway"
    }  
}
# # #IGW 생성
# # resource "aws_internet_gateway" "main_igw" {
# #     vpc_id = data.aws_vpc.main.id
# }
# 퍼블릭 서브넷을 위한 라우팅 테이블 생성
resource "aws_route_table" "public" {
    vpc_id = data.aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "igw-04c0dbe944ddad368" # IGW 연결
    }
    tags = {
      Name = "Io-PublicRT"
    }

}

# 퍼블릭 서브넷에 라우팅 테이블 연결
resource "aws_route_table_association" "publicly_accessible_a" {
    subnet_id = aws_subnet.main.id # ap-southeast-1a 퍼블릭 서브넷 연결
    route_table_id = aws_route_table.public.id
}

# 퍼블릭 서브넷에 라우팅 테이블 연결
resource "aws_route_table_association" "publicly_accessible_b" {
    subnet_id = aws_subnet.main_b.id # ap-southeast-1b 퍼블릭 서브넷 연결
    route_table_id = aws_route_table.public.id
}

#보안그룹 HTTP
resource "aws_security_group" "allow_http" {
    vpc_id = data.aws_vpc.main.id
    name = "allow_http"

ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
}
#보안그룹 HTTPS
resource "aws_security_group" "allow_https" {
    vpc_id = data.aws_vpc.main.id
    name = "allow_https"

ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
}

#보안그룹 SSH
resource "aws_security_group" "allow_ssh" {
    vpc_id = data.aws_vpc.main.id
    name = "allow_ssh"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
# RDS 보안그룹 생성
resource "aws_security_group" "allow_db" {
    vpc_id = data.aws_vpc.main.id
    name = "allow_db"

    ingress {
        from_port   = 3306  # MariaDB 기본 포트
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
# RDS 서브넷 그룹 생성
resource "aws_db_subnet_group" "io_db_subnet_group" {
    name = "io-db-subnet-group"
    subnet_ids = [
        aws_subnet.private_subnet.id, # ap-southeast-1a
        aws_subnet.private_subnet_b.id # ap-southeast-1b
        ]

    tags = {
      Name = "Io-DB-subnet-group"
    } 
}

# Redis 보안 그룹 생성
resource "aws_security_group" "allow_redis" {
    vpc_id = data.aws_vpc.main.id
    name = "allow_redis"

    ingress {
        from_port = 6379 # redis 기본포트
        to_port = 6379
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # 프라이빗 서브넷 접근 허용
}
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"] 
 }
}
# RDS 인스턴스 생성
resource "aws_db_instance" "io_rds" {
    identifier = "io-mariadb-instance"
    engine = "mariadb"
    engine_version = "10.5.26"
    instance_class = "db.t4g.micro"
    allocated_storage = 20
    storage_type = "gp2"
    db_subnet_group_name = aws_db_subnet_group.io_db_subnet_group.name
    vpc_security_group_ids = [aws_security_group.allow_db.id]
    backup_retention_period = 7
    skip_final_snapshot = true
    publicly_accessible = false
    parameter_group_name = "default.mariadb10.5"
    username = "admin"
    password = "admin1234"
    snapshot_identifier = "rds:iotest1234-2025-01-06-19-22" #s3에서 내보낸 RDS 스냅샷 ID
}
    # RDS 엔드포인트 출력
    output "rds_endpoint" {
        value = aws_db_instance.io_rds.endpoint
    }

# Redis 인스턴스 생성
resource "aws_instance" "redis" {
    ami           = "ami-01dee5e721c8a2dd6" # io-cache(redis)AMI 사용
    instance_type = "t2.micro" # Redis 인스턴스 타입
    key_name = "io-key-dev" 
    subnet_id     = aws_subnet.private_subnet.id # Redis를 프라이빗 서브넷에 배치
    security_groups = [aws_security_group.allow_redis.id] # Redis 보안 그룹을 사용하여 접근 허용

    user_data = file("cache_setup.sh")
    tags = {
        Name = "Redis-Cache"
    }
}
# 캐시 서버의 Redis IP를 워드프레스 설정에서 사용하기 위해 정의
# wp-config.php에서 Redis 설정 추가
# define('WP_REDIS_HOST', aws_instance.redis.private_ip);
# define('WP_REDIS_PORT', 6379);  
# 타겟 그룹 생성
resource "aws_lb_target_group" "app_target_group" {
    name = "app-target-group"
    port = 80
    protocol = "HTTP"
    vpc_id = data.aws_vpc.main.id

    health_check {
      path = "/"
      interval = 30
      timeout = 5
      healthy_threshold = 3
      unhealthy_threshold = 3
    }
}
#로드 밸런서 생성
resource "aws_lb" "app_lb" {
    name = "app-lb"
    internal = false
    load_balancer_type = "application"
    security_groups = [
        aws_security_group.allow_http.id,
        aws_security_group.allow_https.id]
    subnets = [
        aws_subnet.main.id, # ap-southeast-1a
        aws_subnet.main_b.id # ap-southeast-1b
        ]

    enable_deletion_protection = false

    tags = {
      Name = "IO-app-load-balancer"
    }
}

#로드밸런서 리스너 생성
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.app_lb.arn
    port = 80
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.app_target_group.arn
    }
}

# launch template 생성
resource "aws_launch_template" "app" {
    name = "IoWeb-launch-template"
    image_id = "ami-03768b0d22d0c6774"
    instance_type = "t2.medium"
    key_name = "io-key-dev" 

    network_interfaces {
      associate_public_ip_address = true
      subnet_id = aws_subnet.main.id
      security_groups = [aws_security_group.allow_http.id, 
                        aws_security_group.allow_https.id, 
                        aws_security_group.allow_ssh.id]
    }
user_data = base64encode(<<-EOF
    #!/bin/bash
    export DB_HOST="${aws_db_instance.io_rds.endpoint}"  # RDS 엔드포인트
    export DB_NAME="io-mariadb-instance"
    export DB_USER="admin"
    export DB_PASSWORD="admin1234"
    export REDIS_HOST="127.0.0.1"
    export REDIS_PORT="6379"

    # wp-config.php 파일 백업 및 수정
    sudo cp /var/www/html/customer/wp-config.php /var/www/html/customer/wp-config.php.bak
    sudo sed -i "s/define('DB_HOST', '.*');/define('DB_HOST', '\$DB_HOST');/" /var/www/html/customer/wp-config.php
    sudo sed -i "s/define('DB_NAME', '.*');/define('DB_NAME', '\$DB_NAME');/" /var/www/html/customer/wp-config.php
    sudo sed -i "s/define('DB_USER', '.*');/define('DB_USER', '\$DB_USER');/" /var/www/html/customer/wp-config.php
    sudo sed -i "s/define('DB_PASSWORD', '.*');/define('DB_PASSWORD', '\$DB_PASSWORD');/" /var/www/html/customer/wp-config.php

    # Redis 설정 추가
    echo "define('WP_REDIS_HOST', '\$REDIS_HOST');" | sudo tee -a /var/www/html/customer/wp-config.php
    echo "define('WP_REDIS_PORT', '\$REDIS_PORT');" | sudo tee -a /var/www/html/customer/wp-config.php

    # Nginx 및 PHP-FPM 서비스 시작 및 활성화
    sudo systemctl start nginx
    sudo systemctl enable nginx

    sudo systemctl start php-fpm
    sudo systemctl enable php-fpm

    # Nginx 및 PHP-FPM 서비스 재시작
    sudo systemctl restart nginx
    sudo systemctl restart php-fpm
EOF
)
                tags = {
                  Name = "io-web-template"
                }

}

#auto scaling group 생성

resource "aws_autoscaling_group" "io-autoscaling" {
    desired_capacity = 1
    max_size = 5
    min_size = 1
    vpc_zone_identifier = [aws_subnet.main.id, aws_subnet.main_b.id]
launch_template {
      id = aws_launch_template.app.id
      version = "$Latest"
    }  

tag {
  key = "Name"
  value = "io-web-server-autosacling"
  propagate_at_launch = true
}
}

#auto scaling 정책
resource "aws_autoscaling_policy" "scale_up" {
    name = "scale_up"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    autoscaling_group_name = aws_autoscaling_group.io-autoscaling.name
}

resource "aws_autoscaling_policy" "scale_down" {
    name = "scale_down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    autoscaling_group_name = aws_autoscaling_group.io-autoscaling.name
}

#cpu 사용률에 대한 cloudwatch 알람( 70프로 초과시 스케일 업)
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
    alarm_name = "high_cpu_alarm"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = "1"
    metric_name = "CPUUtilization"
    namespace = "AWS_EC2"
    period = "60"
    statistic = "Average"
    threshold = "70" # CPU 사용률 70%
    alarm_description = "This alarm triggers scaling up when CPU exceeds 70%"
    alarm_actions = [aws_autoscaling_policy.scale_up.arn]
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.io-autoscaling.name
    }
}

#cpu 사용률에 대한 cloudwatch 알람( 30프로 이하시 스케일 업)
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
    alarm_name = "low_cpu_alarm"
    comparison_operator = "LessThanThreshold"
    evaluation_periods = "1"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "30"
    alarm_description = "This alarm triggers scaling down when CPU is below 30%"
    alarm_actions = [aws_autoscaling_policy.scale_down.arn]
    dimensions = {
      AutoScalingGroupName = aws_autoscaling_group.io-autoscaling.name
    }
}
resource "aws_s3_bucket" "io_web_s3" {
  bucket = "io-web-s3"

  tags = {
    Name = "io-web-s3"
  }
}

# 액세스 차단 비활성화
resource "aws_s3_bucket_public_access_block" "io_web_s3_public_access_block" {
    bucket = aws_s3_bucket.io_web_s3.id

  block_public_acls = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_policy" "io_web_s3_policy" {
  bucket = aws_s3_bucket.io_web_s3.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource  = "${aws_s3_bucket.io_web_s3.arn}/*"
      }
    ]
  })
}
