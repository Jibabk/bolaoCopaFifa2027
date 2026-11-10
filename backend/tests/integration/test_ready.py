import os

import pytest
from fastapi.testclient import TestClient

from app.bootstrap.main import app

REAL_DATABASE_URL = os.getenv("DATABASE_URL")
UNREACHABLE_DATABASE_URL = "postgresql+psycopg://postgres:postgres@127.0.0.1:1/bolao"

client = TestClient(app)


def test_live_does_not_depend_on_database(monkeypatch):
    monkeypatch.setenv("DATABASE_URL", UNREACHABLE_DATABASE_URL)

    response = client.get("/live")

    assert response.status_code == 200


def test_ready_returns_503_when_database_is_unreachable(monkeypatch):
    monkeypatch.setenv("DATABASE_URL", UNREACHABLE_DATABASE_URL)

    response = client.get("/ready")

    assert response.status_code == 503
    assert response.json() == {"status": "unavailable"}


def test_ready_returns_503_when_database_url_is_missing(monkeypatch):
    monkeypatch.delenv("DATABASE_URL", raising=False)

    response = client.get("/ready")

    assert response.status_code == 503


@pytest.mark.skipif(not REAL_DATABASE_URL, reason="requer DATABASE_URL apontando para o PostgreSQL")
def test_ready_returns_200_with_reachable_database(monkeypatch):
    monkeypatch.setenv("DATABASE_URL", REAL_DATABASE_URL)

    response = client.get("/ready")

    assert response.status_code == 200
    assert response.json() == {"status": "ready"}
