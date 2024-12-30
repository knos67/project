## 1. 환경변수
variable "env" {
    type = object({
        name   = string
        region = string
        pf     = string
        })
}

variable "cred" {
    type = object({
        asm_fcm_key_name = string
        asm_client_token_map_name = string
    })
}

variable "userdata_path" {
    type = string
}