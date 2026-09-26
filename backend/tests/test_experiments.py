def test_create_and_get_experiment(client):
    # 1. Create experiment
    payload = {
        "merchant_id": "M001",
        "opportunity_id": "OP001",
        "baseline_amount": 10000.0,
        "experiment_amount": 12500.0,
        "promotion_type": "3-hour combo discount"
    }
    response = client.post("/api/experiments", json=payload)
    assert response.status_code == 201
    created = response.json()
    assert "experiment_id" in created
    assert created["merchant_id"] == "M001"
    assert created["opportunity_id"] == "OP001"
    assert created["baseline_amount"] == 10000.0
    assert created["experiment_amount"] == 12500.0
    assert created["uplift_percent"] == 25.0
    exp_id = created["experiment_id"]

    # 2. Retrieve experiment
    get_res = client.get(f"/api/experiments/{exp_id}")
    assert get_res.status_code == 200
    retrieved = get_res.json()
    assert retrieved["experiment_id"] == exp_id
    assert retrieved["uplift_percent"] == 25.0

def test_create_experiment_invalid_merchant(client):
    payload = {
        "merchant_id": "INVALID_MERCHANT",
        "opportunity_id": "OP001",
        "baseline_amount": 1000.0,
        "experiment_amount": 1200.0
    }
    response = client.post("/api/experiments", json=payload)
    assert response.status_code == 404

def test_create_experiment_invalid_opportunity(client):
    payload = {
        "merchant_id": "M001",
        "opportunity_id": "INVALID_OPPORTUNITY",
        "baseline_amount": 1000.0,
        "experiment_amount": 1200.0
    }
    response = client.post("/api/experiments", json=payload)
    assert response.status_code == 404
