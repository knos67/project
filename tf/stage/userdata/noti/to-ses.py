import json
import boto3
from botocore.exceptions import ClientError

# SES 클라이언트 생성
ses_client = boto3.client('ses', region_name='ap-southeast-1')

def ses_handler(event, context):

    # SQS 메시지 처리
    for record in event['Records']:
        try:
            # SQS 메시지 본문 읽기
            message_body = json.loads(record['body'])
            
            # 필요한 정보 추출 (예: 이메일 제목, 수신자, 메시지 내용)
            sender = message_body.get("sender", "no-reply@example.com")  # 기본 발신자
            recipient = message_body.get("recipient", "recipient@example.com")
            subject = message_body.get("subject", "Default Subject")
            body_text = message_body.get("contents", "Default body content.")
            
            # SES 이메일 전송 요청
            response = ses_client.send_email(
                Source=sender,
                Destination={
                    'ToAddresses': [recipient]
                },
                Message={
                    'Subject': {
                        'Data': subject
                    },
                    'Body': {
                        'Text': {
                            'Data': body_text
                        }
                    }
                }
            )
            
            print(f"Email sent! Message ID: {response['MessageId']}")
        except ClientError as e:
            print(f"Failed to send email: {e.response['Error']['Message']}")
        except Exception as e:
            print(f"Error processing SQS message: {str(e)}")