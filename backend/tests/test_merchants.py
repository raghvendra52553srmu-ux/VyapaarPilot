def test_merchant_summary_success(client):
    response = client.get("/api/merchants/M001/summary")
    assert response.status_code == 200
    data = response.json()
    assert data["merchant_id"] == "M001"
    assert data["merchant_name"] == "Sharma General Store"
    assert data["city"] == "Lucknow"
    assert "today_sales" in data
    assert data["today_sales"] > 0
    assert "current_week_sales" in data
    assert "current_month_sales" in data
    assert "success_rate" in data
    assert "average_transaction_value" in data
    assert data["currency"] == "INR"

def test_merchant_summary_not_found(client):
    response = client.get("/api/merchants/NON_EXISTENT_MERCHANT/summary")
    assert response.status_code == 404
