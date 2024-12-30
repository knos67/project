locals {
    tags = {
        Name    = "${var.env.pf}"
        Service = "${var.env.name}"
    }
}

## 1. SQS
resource "aws_sqs_queue" "mq" {
    name                      = "${local.tags.Name}${var.sqs.name}"
    delay_seconds             = var.sqs.delay_sec
    max_message_size          = var.sqs.maxsize_msg
    message_retention_seconds = var.sqs.retention_sec
    receive_wait_time_seconds = var.sqs.wait_sec
    # redrive_policy            = jsonencode({
    # deadLetterTargetArn = aws_sqs_queue.terraform_queue_deadletter.arn
    # maxReceiveCount     = 4
    #   })
    tags = merge(
        local.tags,
        {
            Name = "${local.tags.Name}${var.sqs.tags.Name}"
        }
    )
}

################################################################
## 2. Lambda

resource "aws_iam_role" "lambda_noti_role" {
    # for_each = var.iam_role
    # name               = each.value.name #"lambda_execution_role"
    # assume_role_policy = file("${var.userdata_path}${each.value.fname}") #iam_lambda_assume_role_policy.json
    # tags               = merge(
    #     local.tags,
    #     {
    #         Name = "${local.tags.Name}${each.value.tags.Name}"
    #     }
    # )
    name = var.iam_role["lambda_noti"].name
    assume_role_policy = file("${var.userdata_path}${var.iam_role["lambda_noti"].fname}")
    tags = merge(
        local.tags,
        {
            Name = "${local.tags.Name}${var.iam_role["lambda_noti"].tags.Name}"
        }
    )
}

resource "aws_iam_policy" "lambda_noti_policy" {
    for_each    = var.iam_policy
    name        = each.value.name #"lambda_combined_policy"
    description = "${each.value.description}"#"Combined policy for SES, SNS, SMS, SQS, and CloudWatch Logs"
    policy      = file("${var.userdata_path}${each.value.fname}") #iam_lambda_policy.json
    tags        = merge(
        local.tags,
        {
            Name = "${local.tags.Name}${each.value.tags.Name}"
        }
    )
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
    for_each    = aws_iam_policy.lambda_noti_policy
    role       = aws_iam_role.lambda_noti_role.name
    policy_arn = each.value.arn
}

data "archive_file" "lambda_file" {
    for_each    = var.lambda.file
    type        = "${each.value.ftype-out}" #"zip"
    source_file = "${var.userdata_path}${each.value.fname-in}.${each.value.ftype-in}"
    output_path = "${var.userdata_path}${each.value.fname-out}.${each.value.ftype-out}"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  for_each = var.lambda.conf
  name              = "/aws/lambda/${var.env.pf}-lambda-${each.value.lname}"
  retention_in_days = 14
}

resource "aws_lambda_function" "lambda_func" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
    for_each      = var.lambda.conf

    filename      = "${var.userdata_path}${each.value.lname}.${var.lambda.file[each.key].ftype-out}"
    function_name = "${var.env.pf}-lamdba-${each.value.lname}"
    role          = aws_iam_role.lambda_noti_role.arn
    handler       = "${each.value.handler}" #"lambda_function.lambda_handler"

    source_code_hash = data.archive_file.lambda_file[each.key].output_base64sha256

    runtime = "${each.value.runtime}" #"python3.13"
    architectures = each.value.architectures #"x86_64"
    ephemeral_storage {
        size = each.value.storage_size
    }
    memory_size = each.value.memory_size

    # cloudwatch logs
    logging_config {
        log_format = "Text"
    }

    depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment["lambda_logs"],
    aws_cloudwatch_log_group.lambda_log_group
    ]

    tags = merge(
        local.tags,
        {
            Name = "${local.tags.Name}${each.value.tags.Name}"
        }
    )
}

resource "aws_lambda_event_source_mapping" "lambda_trigger" {
    for_each         = var.lambda.conf
    event_source_arn = aws_sqs_queue.mq.arn
    function_name    = aws_lambda_function.lambda_func[each.key].arn

    filter_criteria {
        filter {
        pattern = file("${var.userdata_path}${each.value.filtername}.json")
        }
    }
    tags = merge(
        local.tags,
        {
            Name = "${local.tags.Name}${each.value.tags.Name}"
        }
    )
}


################################################################
##  3. SNS 

### 1. Firebase Cloud Messaging (FCM) API Key
# data "aws_secretsmanager_secret" "gcm_api_key" {
#     name = "${var.cred.fcm_key_name}"
# }

data "aws_secretsmanager_secret_version" "gcm_api_key" {
  secret_id = var.cred.asm_fcm_key_name
}

### 2. Platform Application
resource "aws_sns_platform_application" "platapp" {
    # arn                          = "arn:aws:sns:ap-southeast-1:442042508568:app/GCM/io-dev-sns-test_plantform_application-android"
    # id                           = "arn:aws:sns:ap-southeast-1:442042508568:app/GCM/io-dev-sns-test_plantform_application-android"
      name                         = "${var.env.pf}${var.sns.name}"#-sns-platapp
      platform                     = "GCM"
      success_feedback_sample_rate = "100"
      platform_credential          = data.aws_secretsmanager_secret_version.gcm_api_key.secret_string
}

### 3. Platapp Endpoint (AWS CLI 사용)

data "aws_secretsmanager_secret_version" "token_map" {
  secret_id = var.cred.asm_client_token_map_name
}

locals {
  decoded_secrets = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.token_map.secret_string))
}


resource "null_resource" "create_endpoint" {
    for_each = local.decoded_secrets
    provisioner "local-exec" {
            
        command = <<EOT
        aws sns create-platform-endpoint --platform-application-arn ${aws_sns_platform_application.platapp.arn} --token ${each.value} --custom-user-data ${each.key}
        EOT
    }
     # 의존성 추가
     depends_on = [aws_sns_platform_application.platapp]
}

## 4. SES
# Identity 가 추가되면 좋으나, 수동 인증이 필요한 사항이기에 따로 적지 않는다.
# contact list 또한 본 프로젝트의 범위를 벗어난다 판단, 다루지 않는다.