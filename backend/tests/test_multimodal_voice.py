import io
import wave
import struct

def _create_dummy_wav_bytes(duration_sec: float = 0.5) -> bytes:
    sample_rate = 16000
    num_samples = int(sample_rate * duration_sec)
    wav_io = io.BytesIO()
    with wave.open(wav_io, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        frames = bytearray()
        for i in range(num_samples):
            sample_val = int(1000 * (i % 20))
            frames.extend(struct.pack("<h", sample_val))
        wf.writeframes(frames)
    return wav_io.getvalue()

def test_capabilities_endpoint(client):
    response = client.get("/api/capabilities")
    assert response.status_code == 200
    data = response.json()
    assert data["text_chat"] is True
    assert data["voice_input"] is True
    assert data["voice_output"] is True
    assert data["realtime"] is True
    assert "hinglish" in data["languages"]
    assert "audio/wav" in data["audio_formats"]

def test_voice_endpoint_valid_audio(client):
    audio_bytes = _create_dummy_wav_bytes(0.5)
    files = {
        "audio": ("test_speech.wav", audio_bytes, "audio/wav")
    }
    data = {
        "merchant_id": "M001",
        "language": "hinglish",
        "response_mode": "both"
    }
    response = client.post("/api/ai/voice", data=data, files=files)
    assert response.status_code == 200
    res = response.json()
    assert "conversation_id" in res
    assert res["input"]["type"] == "voice"
    assert "transcript" in res["input"]
    assert len(res["response"]["text"]) > 5
    assert "audio" in res
    assert res["audio"]["audio_available"] is True
    assert res["audio"]["audio_url"] is not None

    # Test retrieving synthesized audio stream
    audio_url = res["audio"]["audio_url"]
    audio_res = client.get(audio_url)
    assert audio_res.status_code == 200
    assert audio_res.headers["content-type"] in ["audio/wav", "audio/mpeg"]
    assert len(audio_res.content) > 100

def test_voice_endpoint_empty_audio(client):
    files = {
        "audio": ("empty.wav", b"", "audio/wav")
    }
    data = {
        "merchant_id": "M001",
        "language": "hinglish"
    }
    response = client.post("/api/ai/voice", data=data, files=files)
    assert response.status_code == 400
    err = response.json()
    assert err["error"]["code"] == "EMPTY_AUDIO"

def test_voice_endpoint_unsupported_mime(client):
    files = {
        "audio": ("notes.txt", b"not audio data at all 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890", "text/plain")
    }
    data = {
        "merchant_id": "M001",
        "language": "hinglish"
    }
    response = client.post("/api/ai/voice", data=data, files=files)
    assert response.status_code == 400
    err = response.json()
    assert err["error"]["code"] == "INVALID_AUDIO_FORMAT"

def test_action_confirmation_and_execution_flow(client):
    # 1. User asks to start experiment
    ask_payload = {
        "merchant_id": "M001",
        "message": "Tuesday evening ke liye experiment start karo",
        "language": "hinglish"
    }
    response = client.post("/api/ai/ask", json=ask_payload)
    assert response.status_code == 200
    res = response.json()
    
    # Must contain a confirmation action
    actions = res["actions"]
    confirm_action = next((a for a in actions if a["requires_confirmation"] is True), None)
    assert confirm_action is not None
    assert confirm_action["tool"] == "create_experiment"
    action_id = confirm_action["id"]

    # 2. Merchant approves action via Flutter confirmation sheet -> execute action
    exec_payload = {
        "merchant_id": "M001",
        "action_id": action_id
    }
    exec_response = client.post("/api/ai/action/execute", json=exec_payload)
    assert exec_response.status_code == 200
    exec_data = exec_response.json()
    assert exec_data["status"] == "success"
    assert exec_data["tool"] == "create_experiment"
    assert "experiment_id" in exec_data["result"]
    assert exec_data["result"]["uplift_percent"] > 0
