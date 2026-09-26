def test_merchant_trends(client):
    response = client.get("/api/merchants/M001/trends?period=7d")
    assert response.status_code == 200
    data = response.json()
    assert data["merchant_id"] == "M001"
    assert "daily_trends" in data
    assert isinstance(data["daily_trends"], list)
    assert len(data["daily_trends"]) > 0
    assert "tuesday_hourly_baseline" in data
    assert isinstance(data["tuesday_hourly_baseline"], list)

def test_merchant_trends_not_found(client):
    response = client.get("/api/merchants/INVALID_ID/trends")
    assert response.status_code == 404
