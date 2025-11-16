import boto3
from datetime import datetime

def handler(event, context):
    now = datetime.utcnow().strftime("%Y-%m-%d_%H-%M-%S")
    filename = f"{now}.txt"

    s3 = boto3.client("s3")
    bucket = "${bucket}"

    s3.put_object(
        Bucket=bucket,
        Key=filename,
        Body=f"Arquivo gerado em {now} UTC"
    )

    return {"status": "ok", "file": filename}