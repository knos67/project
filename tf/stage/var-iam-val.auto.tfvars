iam_role = {
    "lambda_noti" = {
        name = "lambda_execution_role"
        fname = "iam_lambda_noti_arpolicy.json"
        tags = {
            Name = "-iam-role-lambda-noti"
        }
    }
}
    
iam_policy = {
    "lambda_exec" = {
        name = "lambda_combined_policy"
        description = "Combined policy for SES, SNS, SMS, SQS"
        fname = "iam_lambda_noti_exec_policy.json"
        tags = {
            Name = "-iam-policy-lambda-noti-exec"
        }
    }
    "lambda_logs" = {
        name = "lambda_logs_policy"
        description = "Policy for CloudWatch Logs"
        fname = "iam_lambda_noti_logs_policy.json"
        tags = {
            Name = "-iam-policy-lambda-noti-logs"
        }
    }
}
