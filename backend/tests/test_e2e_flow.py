"""
End-to-End (E2E) System Tests for VyapaarPilot.
Tests the entire merchant journey:
1. Health & Capabilities
2. Merchant Analytics & Opportunity Detection
3. Text Conversation (Grounded with Groq/Mock)
4. Voice Conversation (WAV Upload -> STT -> Agent -> TTS -> Audio Stream)
5. Action Confirmation & Safe Execution Guardrails
6. Realtime WebSocket Turn Lifecycle
7. Error & Security Boundary Validation
"""

import io
import wave
import struct
import pytest
from fastapi.testclient import TestClient

def create_synthetic_wav_bytes(duration_sec: float = 1.0, freq: float = 440.0, sample_rate: int = 16000) -> bytes:
    """Helper to synthesize valid PCM WAV bytes."""
    buf = io.BytesIO()
    with wave.open(buf, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        import math
        num_samples = int(duration_sec * sample_rate)
        samples = []
        for i in range(num_samples):
            val = int(32767.0 * 0.5 * math.sin(2.0 * math.pi * freq * (i / sample_rate)))
            samples.append(struct.pack("<h", val))
        wf.writeframes(b"".join(samples))
    return buf.getvalue()

# ============================================================================
# 1. Health & Capabilities Check
# ============================================================================
def test_e2e_01_health_and_capabilities(client: TestClient):
    # 1. Health check
    res_health = client.get("/api/health")
    assert res_health.status_code == 200
    health_data = res_health.json()
    assert health_data["status"] == "ok"
    assert health_data["database"] == "connected"

    # 2. Capabilities check
    res_cap = client.get("/api/capabilities")
    assert res_cap.status_code == 200
    cap_data = res_cap.json()
    assert cap_data["text_chat"] is True
    assert cap_data["voice_input"] is True
    assert cap_data["voice_output"] is True
    assert cap_data["realtime"] is True
    assert "hinglish" in cap_data["languages"]
    assert "audio/wav" in cap_data["audio_formats"]

# ============================================================================
# 2. Analytics & Opportunity Detection Pipeline
# ============================================================================
def test_e2e_02_analytics_and_opportunities(client: TestClient):
    # 1. Verify merchant M001 exists
    res_merchants = client.get("/api/merchants/")
    assert res_merchants.status_code == 200
    merchants = res_merchants.json()
    assert any(m["merchant_id"] == "M001" for m in merchants)

    # 2. Fetch merchant summary
    res_summary = client.get("/api/analytics/summary?merchant_id=M001")
    assert res_summary.status_code == 200
    summary = res_summary.json()
    assert "today_sales" in summary
    assert "today_transaction_count" in summary
    assert "success_rate" in summary
    assert summary["success_rate"] >= 0.0

    # 3. Fetch trends & Tuesday baseline
    res_trends = client.get("/api/analytics/trends?merchant_id=M001&period=7d")
    assert res_trends.status_code == 200
    trends = res_trends.json()
    assert "daily_trends" in trends
    assert "tuesday_hourly_baseline" in trends

    # 4. Detect opportunities
    res_opps = client.get("/api/opportunities/?merchant_id=M001")
    assert res_opps.status_code == 200
    opps = res_opps.json()
    assert isinstance(opps, list)
    tue_opp = next((o for o in opps if o.get("opportunity_id") == "OP001" or o.get("type") in ["slow_period", "TUESDAY_EVENING_SLOWDOWN"]), None)
    assert tue_opp is not None
    assert tue_opp["baseline_amount"] > 0

# ============================================================================
# 3. Multimodal Conversation Turn (Text -> Grounded Facts)
# ============================================================================
def test_e2e_03_text_conversation_grounding(client: TestClient):
    payload = {
        "merchant_id": "M001",
        "message": "Bhai Tuesday evening mein meri sales kyun gir rahi hai?",
        "language": "hinglish",
        "response_mode": "text"
    }
    res = client.post("/api/ai/ask", json=payload)
    assert res.status_code == 200
    data = res.json()

    # Verify unified conversation response contract
    assert "conversation_id" in data
    assert "message_id" in data
    assert data["input"]["type"] == "text"
    assert "response" in data
    assert len(data["response"]["text"]) > 10
    assert data["intent"] in ["ANALYTICS_QUERY", "OPPORTUNITY_QUERY"]

    # Verify grounding & evidence
    assert len(data["data_used"]) > 0
    assert len(data["evidence"]) > 0
    assert "actions" in data
    assert len(data["actions"]) > 0
    assert "latency_ms" in data["metadata"]

# ============================================================================
# 4. Multimodal Voice Turn (Audio Upload -> STT -> Agent -> TTS Stream)
# ============================================================================
def test_e2e_04_voice_conversation_lifecycle(client: TestClient):
    wav_bytes = create_synthetic_wav_bytes(duration_sec=0.5)

    files = {
        "audio": ("query.wav", wav_bytes, "audio/wav")
    }
    data = {
        "merchant_id": "M001",
        "language": "hinglish",
        "response_mode": "both"
    }

    res = client.post("/api/ai/voice", files=files, data=data)
    assert res.status_code == 200
    voice_res = res.json()

    # Verify input transcription
    assert voice_res["input"]["type"] == "voice"
    assert "transcript" in voice_res["input"]
    assert len(voice_res["input"]["transcript"]) > 0

    # Verify agent response
    assert len(voice_res["response"]["text"]) > 0

    # Verify audio generation and audio playback URL
    assert "audio" in voice_res
    assert voice_res["audio"]["audio_available"] is True
    audio_url = voice_res["audio"]["audio_url"]
    assert audio_url is not None
    assert "/api/ai/voice/audio/" in audio_url

    # Test downloading the synthesized audio stream
    audio_endpoint = audio_url.replace("http://testserver", "")
    stream_res = client.get(audio_endpoint)
    assert stream_res.status_code == 200
    assert stream_res.headers.get("content-type", "") in ["audio/wav", "audio/mpeg"]
    assert len(stream_res.content) > 44

# ============================================================================
# 5. Safe Action Execution Guardrail (Confirmation flow)
# ============================================================================
def test_e2e_05_action_confirmation_guardrail(client: TestClient):
    # 1. Unconfirmed write execution must be rejected
    unconfirmed_payload = {
        "action_id": "act_test_001",
        "tool": "create_experiment",
        "arguments": {
            "merchant_id": "M001",
            "opportunity_id": "OP001"
        },
        "confirmed": False
    }
    res_unconfirmed = client.post("/api/ai/action/execute", json=unconfirmed_payload)
    assert res_unconfirmed.status_code == 400
    err = res_unconfirmed.json()
    assert err["error"]["code"] == "TOOL_CONFIRMATION_REQUIRED"

    # 2. Confirmed write execution succeeds safely
    confirmed_payload = {
        "action_id": "act_test_002",
        "tool": "create_experiment",
        "arguments": {
            "merchant_id": "M001",
            "opportunity_id": "OP001"
        },
        "confirmed": True
    }
    res_confirmed = client.post("/api/ai/action/execute", json=confirmed_payload)
    assert res_confirmed.status_code == 200
    res_data = res_confirmed.json()
    assert res_data["success"] is True
    assert "experiment_id" in res_data["result"]
    assert res_data["result"]["status"] == "completed"
    assert res_data["result"]["uplift_percent"] > 0

# ============================================================================
# 6. Realtime WebSocket Interactive Session
# ============================================================================
def test_e2e_06_realtime_websocket_session(client: TestClient):
    with client.websocket_connect("/api/ai/realtime/M001") as ws:
        # Start session
        ws.send_json({"type": "session.start", "language": "hinglish"})
        ready_evt = ws.receive_json()
        assert ready_evt["type"] == "session.ready"

        # Send text turn
        ws.send_json({"type": "text.message", "text": "Aaj ki sale kaisi hai?"})

        events = []
        while True:
            evt = ws.receive_json()
            events.append(evt)
            if evt["type"] in ["response.done", "error"]:
                break

        evt_types = [e["type"] for e in events]
        assert "agent.thinking" in evt_types
        assert "response.text.done" in evt_types
        assert "response.done" in evt_types

# ============================================================================
# 7. Error & Security Boundary Validation
# ============================================================================
def test_e2e_07_error_and_security_boundaries(client: TestClient):
    # 1. Invalid audio MIME type
    bad_file = {"audio": ("virus.exe", b"not an audio", "application/x-msdownload")}
    res_mime = client.post("/api/ai/voice", files=bad_file, data={"merchant_id": "M001"})
    assert res_mime.status_code == 400
    assert res_mime.json()["error"]["code"] == "INVALID_AUDIO_FORMAT"

    # 2. Empty audio file
    empty_file = {"audio": ("empty.wav", b"", "audio/wav")}
    res_empty = client.post("/api/ai/voice", files=empty_file, data={"merchant_id": "M001"})
    assert res_empty.status_code == 400
    assert res_empty.json()["error"]["code"] in ["EMPTY_AUDIO", "EMPTY_AUDIO_FILE", "INVALID_AUDIO_FORMAT"]

    # 3. Invalid tool execution attempt
    bad_tool_payload = {
        "action_id": "act_bad",
        "tool": "drop_database_tables",
        "arguments": {},
        "confirmed": True
    }
    res_bad_tool = client.post("/api/ai/action/execute", json=bad_tool_payload)
    assert res_bad_tool.status_code == 400
    assert res_bad_tool.json()["error"]["code"] == "TOOL_VALIDATION_FAILED"
