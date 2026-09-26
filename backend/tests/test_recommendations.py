def test_generate_recommendation_hinglish(client):
    payload = {
        "merchant_id": "M001",
        "preferred_language": "hinglish"
    }
    response = client.post("/api/opportunities/OP001/recommend", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["opportunity_id"] == "OP001"
    assert "recommendation" in data
    assert "reason" in data
    assert "supporting_evidence" in data
    assert "safety_limitation" in data
    assert data["confidence"] > 0
    # Safety checks
    rec_text = data["recommendation"].lower()
    assert "loan" not in rec_text
    assert "borrow" not in rec_text

def test_generate_recommendation_english(client):
    payload = {
        "merchant_id": "M001",
        "preferred_language": "en"
    }
    response = client.post("/api/opportunities/OP001/recommend", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "Tuesday" in data["title"] or "Slowdown" in data["title"]
    assert "safety_limitation" in data
