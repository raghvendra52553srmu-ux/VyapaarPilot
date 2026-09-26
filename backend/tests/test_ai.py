def test_ai_ask_general_knowledge(client):
    payload = {
        "merchant_id": "M001",
        "question": "What is UPI?",
        "language": "en"
    }
    response = client.post("/api/ai/ask", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "UPI" in data["answer"]
    assert data["intent"] == "GENERAL_KNOWLEDGE_QUERY"
    assert data["data_used"] == []  # No merchant DB data required for general knowledge

def test_ai_ask_sales_decline_hinglish(client):
    payload = {
        "merchant_id": "M001",
        "question": "Meri sale kyu kam hui?",
        "language": "hi"
    }
    response = client.post("/api/ai/ask", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "answer" in data
    assert len(data["answer"]) > 10
    # Data grounding check: must have retrieved data first
    assert len(data["data_used"]) > 0
    assert len(data["evidence"]) > 0
    assert "suggested_actions" in data

def test_ai_ask_sales_decline_english(client):
    payload = {
        "merchant_id": "M001",
        "question": "Why are my sales declining?",
        "language": "en"
    }
    response = client.post("/api/ai/ask", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "answer" in data
    assert "Tuesday" in data["answer"] or "sales" in data["answer"].lower()
    assert len(data["data_used"]) > 0

def test_ai_ask_ambiguous(client):
    payload = {
        "merchant_id": "M001",
        "question": "sales?",
        "language": "en"
    }
    response = client.post("/api/ai/ask", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["intent"] == "AMBIGUOUS_QUERY"
    assert len(data["suggested_actions"]) > 0
