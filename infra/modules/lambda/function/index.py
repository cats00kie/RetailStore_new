import json
import os
import boto3
import base64
import gzip

KEYWORDS = ["ERROR", "FATAL", "PANIC", "EXCEPTION", "CRITICAL"]

def lambda_handler(event, context):
    sns = boto3.client("sns")
    topic_arn = os.environ["SNS_TOPIC_ARN"]

    # los logs de cloudwatch llegan comprimidos
    data = json.loads(gzip.decompress(base64.b64decode(event["awslogs"]["data"])))
    log_group = data["logGroup"]

    errors = []
    for e in data["logEvents"]:
        if any(kw in e["message"].upper() for kw in KEYWORDS):
            errors.append(e["message"])

    if errors:
        msg = f"Se detectaron {len(errors)} errores en {log_group}:\n\n" + "\n\n".join(errors[:10])
        sns.publish(TopicArn=topic_arn, Subject=f"[RetailStore] Error en {log_group}", Message=msg)

    return {"statusCode": 200}
