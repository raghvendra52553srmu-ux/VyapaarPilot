def test_health_endpoint(client):
    response = client.get("/api/health")
    assert response.status_code in [200, 503]
    data = response.json()
    assert "status" in data
    assert "database" in data
    if response.status_code == 200:
        assert data["status"] == "ok"
        assert data["database"] == "connected"

def test_root_endpoint(client):
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "online"
    assert "VyapaarPilot" in data["project"]
