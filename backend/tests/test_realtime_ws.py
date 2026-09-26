import json

def test_websocket_realtime_protocol(client):
    with client.websocket_connect("/api/ai/realtime/M001") as websocket:
        # 1. Send session.start
        websocket.send_text(json.dumps({
            "type": "session.start",
            "language": "hinglish"
        }))
        ready_msg = websocket.receive_json()
        assert ready_msg["type"] == "session.ready"
        assert ready_msg["merchant_id"] == "M001"

        # 2. Send text.message
        websocket.send_text(json.dumps({
            "type": "text.message",
            "text": "Meri sale kyu kam hui?"
        }))
        
        # Expect thinking event
        evt1 = websocket.receive_json()
        assert evt1["type"] == "agent.thinking"

        # Expect response.text.done
        evt2 = websocket.receive_json()
        assert evt2["type"] == "response.text.done"
        assert len(evt2["text"]) > 10

        # Expect response.done
        evt3 = websocket.receive_json()
        assert evt3["type"] == "response.done"
        assert "payload" in evt3
        assert evt3["payload"]["intent"] == "ANALYTICS_QUERY"
