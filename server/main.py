import mimetypes
import os
import random
from functools import lru_cache
from dotenv import load_dotenv

import boto3
from botocore.exceptions import ClientError
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response

load_dotenv()

app = FastAPI(title="random-cats")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

S3_BUCKET_NAME = os.environ["S3_BUCKET_NAME"]
S3_PREFIX = os.environ.get("S3_PREFIX", "")


@lru_cache
def get_s3_client():
    return boto3.Session().client("s3")


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/photo")
def random_photo():
    s3 = get_s3_client()

    try:
        response = s3.list_objects_v2(Bucket=S3_BUCKET_NAME)
    except ClientError as e:
        raise HTTPException(status_code=502, detail="Could not list photos from S3") from e

    keys = [obj["Key"] for obj in response.get("Contents", []) if not obj["Key"].endswith("/")]
    if not keys:
        raise HTTPException(status_code=404, detail="No photos found in bucket")

    key = random.choice(keys)

    try:
        obj = s3.get_object(Bucket=S3_BUCKET_NAME, Key=key)
    except ClientError as e:
        raise HTTPException(status_code=502, detail="Could not retrieve photo from S3") from e

    content_type = obj.get("ContentType") or mimetypes.guess_type(key)[0] or "application/octet-stream"
    return Response(
        content=obj["Body"].read(),
        media_type=content_type,
        headers={"Cache-Control": "no-store"},
    )
