import boto3
import json
import snowflake.connector

def get_secret(secret_name, region_name="ap-south-1"):
    client = boto3.client("secretsmanager", region_name=region_name)
    response = client.get_secret_value(SecretId=secret_name)
    secret = json.loads(response["SecretString"])
    return secret

def get_snowflake_connection():
    secret = get_secret("snowflake/enterprise/credentials")
    conn = snowflake.connector.connect(
        user=secret["username"],
        password=secret["password"],
        account=secret["account"],
        warehouse=secret["warehouse"],
        database=secret["database"],
        schema=secret["schema"],
        role=secret["role"]
    )
    return conn
