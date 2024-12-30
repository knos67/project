import json
import boto3
from botocore.exceptions import ClientError

# SNS 클라이언트 생성
sns_client = boto3.client('sns', region_name='ap-southeast-1')

def sns_handler(event, context):

    for record in event['Records']:
        try:
            # SQS 메시지 본문 읽기 및 JSON 파싱
            message_body = json.loads(record['body'])

            # 메시지 유형 확인
            # message_type = message_body.get('type')
            # if message_type != 'push':
            #     print(f"Ignored message with type: {message_type}")
            #     continue

            # 푸시 알림 데이터 추출
            endpoint_arn = message_body.get('endpoint_arn')
            title = message_body.get('title', 'Notification')
            message = message_body.get('message', 'You have a new notification!')

            if not endpoint_arn:
                print("Error: Missing endpoint_arn.")
                continue

            # 푸시 알림 전송 요청
            payload = {
                "default": message,
                "APNS": json.dumps({
                    "aps": {
                        "alert": {
                            "title": title,
                            "body": message
                        },
                        "sound": "default"
                    }
                }),
                "GCM": json.dumps({
                    "notification": {
                        "title": title,
                        "body": message
                    }
                })
            }

            response = sns_client.publish(
                TargetArn=endpoint_arn,
                Message=json.dumps(payload),
                MessageStructure='json'
            )

            print(f"Push notification sent! Message ID: {response['MessageId']}")

        except ClientError as e:
            print(f"Failed to send push notification: {e.response['Error']['Message']}")
        except Exception as e:
            print(f"Error processing SQS message: {str(e)}")