from io import BytesIO
from unittest.mock import MagicMock, patch

from botocore.exceptions import ClientError
from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_health():
    response = client.get("/api/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


@patch("main.get_s3_client")
def test_random_photo_returns_image_bytes(mock_get_s3_client):
    mock_s3 = MagicMock()
    mock_get_s3_client.return_value = mock_s3
    mock_s3.list_objects_v2.return_value = {
        "Contents": [{"Key": "cat1.jpg"}, {"Key": "cat2.jpg"}]
    }
    mock_s3.get_object.return_value = {
        "Body": BytesIO(b"fake-image-bytes"),
        "ContentType": "image/jpeg",
    }

    response = client.get("/api/photo")

    assert response.status_code == 200
    assert response.headers["content-type"] == "image/jpeg"
    assert response.content == b"fake-image-bytes"
    assert response.headers["cache-control"] == "no-store"


@patch("main.get_s3_client")
def test_random_photo_skips_folder_keys(mock_get_s3_client):
    mock_s3 = MagicMock()
    mock_get_s3_client.return_value = mock_s3
    mock_s3.list_objects_v2.return_value = {
        "Contents": [{"Key": "some-folder/"}, {"Key": "cat1.jpg"}]
    }
    mock_s3.get_object.return_value = {
        "Body": BytesIO(b"fake-image-bytes"),
        "ContentType": "image/jpeg",
    }

    response = client.get("/api/photo")

    assert response.status_code == 200
    mock_s3.get_object.assert_called_once_with(Bucket="test-bucket", Key="cat1.jpg")


@patch("main.get_s3_client")
def test_random_photo_empty_bucket_returns_404(mock_get_s3_client):
    mock_s3 = MagicMock()
    mock_get_s3_client.return_value = mock_s3
    mock_s3.list_objects_v2.return_value = {"Contents": []}

    response = client.get("/api/photo")

    assert response.status_code == 404


@patch("main.get_s3_client")
def test_random_photo_list_failure_returns_502(mock_get_s3_client):
    mock_s3 = MagicMock()
    mock_get_s3_client.return_value = mock_s3
    mock_s3.list_objects_v2.side_effect = ClientError(
        {"Error": {"Code": "AccessDenied", "Message": "denied"}}, "ListObjectsV2"
    )

    response = client.get("/api/photo")

    assert response.status_code == 502


@patch("main.get_s3_client")
def test_random_photo_get_object_failure_returns_502(mock_get_s3_client):
    mock_s3 = MagicMock()
    mock_get_s3_client.return_value = mock_s3
    mock_s3.list_objects_v2.return_value = {"Contents": [{"Key": "cat1.jpg"}]}
    mock_s3.get_object.side_effect = ClientError(
        {"Error": {"Code": "NoSuchKey", "Message": "missing"}}, "GetObject"
    )

    response = client.get("/api/photo")

    assert response.status_code == 502
