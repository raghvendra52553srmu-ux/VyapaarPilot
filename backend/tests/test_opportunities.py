def test_get_merchant_opportunities(client):
    response = client.get("/api/merchants/M001/opportunities")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) > 0
    opp = data[0]
    assert "opportunity_id" in opp
    assert "baseline_amount" in opp
    assert "change_percent" in opp
    assert "confidence" in opp

def test_get_single_opportunity_detail(client):
    response = client.get("/api/opportunities/OP001")
    assert response.status_code == 200
    data = response.json()
    assert data["opportunity_id"] == "OP001"
    assert data["merchant_id"] == "M001"
    assert data["type"] == "slow_period"
    assert "baseline_amount" in data
    assert "current_amount" in data
    assert "change_percent" in data
    assert data["confidence"] > 0

def test_get_opportunity_not_found(client):
    response = client.get("/api/opportunities/NON_EXISTENT")
    assert response.status_code == 404
