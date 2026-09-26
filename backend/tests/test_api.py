from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["status"] == "online"

def test_merchant_summary():
    response = client.get("/api/merchants/M001/summary")
    assert response.status_code == 200
    data = response.json()
    assert data["merchant_id"] == "M001"
    assert "today_sales" in data

def test_merchant_opportunities():
    response = client.get("/api/merchants/M001/opportunities")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) > 0
    assert data[0]["opportunity_id"] == "OP001"
