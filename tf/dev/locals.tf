# .auto.tfvars에서 참조하기 위한 로컬 변수 생성
locals {
    pf = "${var.pf}"
}