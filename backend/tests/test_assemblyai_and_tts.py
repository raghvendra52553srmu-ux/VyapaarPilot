# pyrefly: ignore [missing-import]
import pytest
from app.voice.stt.provider import AssemblyAISTTProvider, get_stt_provider
from app.voice.tts.provider import AssemblyAITTSProvider, EdgeTTSProvider, MockTTSProvider, get_tts_provider

@pytest.mark.anyio
async def test_assemblyai_provider_initialization():
    provider = AssemblyAISTTProvider(api_key="test_assembly_key")
    assert provider.provider_name == "assemblyai_stt"
    assert provider.upload_url == "https://api.assemblyai.com/v2/upload"
    assert provider.transcript_url == "https://api.assemblyai.com/v2/transcript"

@pytest.mark.anyio
async def test_edge_tts_provider_voice_selection():
    tts = EdgeTTSProvider()
    assert tts.provider_name == "edge_tts"
    assert tts._select_voice("hi", "नमस्ते") == "hi-IN-MadhurNeural"
    assert tts._select_voice("hinglish", "Bhai meri sales batao") == "hi-IN-MadhurNeural"
    assert tts._select_voice("en", "Why are sales declining?") == "en-IN-PrabhatNeural"

@pytest.mark.anyio
async def test_assemblyai_tts_provider():
    tts = AssemblyAITTSProvider(api_key="test_assembly_key")
    assert tts.provider_name == "assemblyai"
    res = await tts.synthesize("Namaste Sharma ji", language="hinglish")
    assert res.provider == "assemblyai"
    assert len(res.audio_bytes) > 0

@pytest.mark.anyio
async def test_get_tts_provider_defaults_to_assemblyai():
    tts = get_tts_provider()
    assert isinstance(tts, AssemblyAITTSProvider)
    assert tts.provider_name == "assemblyai"

