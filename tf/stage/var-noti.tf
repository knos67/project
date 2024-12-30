## 1. SQS
variable "sqs" {
    type  = object({
    name          = string
    delay_sec     = number
    maxsize_msg   = number
    retention_sec = number
    wait_sec      = number
    tags          = object({
        Name = string
    })
  })
}

## 2. lambda
variable "lambda" {
  type = object({
    file = map(object({
      ftype-in  = string
      fname-in  = string
      ftype-out = string
      fname-out = string
    }))
    conf = map(object({
      lname = string
      runtime = string
      handler = string
      timeout = number
      storage_size = number
      memory_size = number
      architectures = list(string)
      filtername = string
      # environment = map(string)
      tags = object({
        Name = string
      })
    }))
  })
}

## 3. SES



## 4. SNS
variable "sns" {
    type = object({
        name = string
    })
}