def test_customer_analytics(client):
    response = client.get("/api/merchants/M001/customers/analytics")
    assert response.status_code == 200
    data = response.json()
    assert data["merchant_id"] == "M001"
    assert "total_customers" in data
    assert data["total_customers"] > 0
    assert "repeat_customers" in data
    assert "customer_activity_summary" in data
    # Ensure no PII in customer activity summary
    summary = data["customer_activity_summary"]
    assert "@" not in summary  # no emails
    assert "+91" not in summary  # no phone numbers
