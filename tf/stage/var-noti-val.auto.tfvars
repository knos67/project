## 1. SQS
 sqs  = {
    name          = "-sqs-mq"
    delay_sec     = 0
    maxsize_msg   = 262144
    retention_sec = 86400
    wait_sec      = 10
    tags          = {
        Name = "-sqs-mq"
    }
}

# 2. lambda
## 2. lambda
lambda = {
    file = {
        "to-ses" = {
            ftype-in  = "py"
            fname-in  = "to-ses"
            ftype-out = "zip"
            fname-out = "to-ses"
        }
        "to-sns" = {
            ftype-in  = "py"
            fname-in  = "to-sns"
            ftype-out = "zip"
            fname-out = "to-sns"
        }
    }
    conf = {
        "to-ses" = {
            lname = "to-ses"
            runtime = "python3.13"
            handler = "ses_handler" # to-ses.py 에서 정의
            timeout = 10
            storage_size = 512
            memory_size = 128
            architectures = ["arm64"]
            filtername = "event_source_filter_ses"
            # environment = map(string)
            tags = {
                Name = "-lamdba-to-ses"
            }
        }
        "to-sns" = {
            lname = "to-sns"
            runtime = "python3.13"
            handler = "sns_handler" # to-sns.py 에서 정의
            timeout = 10
            storage_size = 512
            memory_size = 128
            architectures = ["arm64"]
            filtername = "event_source_filter_sns"
            # environment = map(string)
            tags = {
                Name = "-lamdba-to-sns"
            }
        }
    }
}


# 3. SNS
sns = {
    name = "-sns-platapp"
}

# 4. SES