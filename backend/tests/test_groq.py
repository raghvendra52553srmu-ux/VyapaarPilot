import pytest
from app.ai.providers.groq_provider import GroqProvider
from app.ai.base import AICompletionRequest
from app.voice.stt.provider import GroqSTTProvider

@pytest.mark.anyio
async def test_groq_provider_initialization():
    provider = GroqProvider(api_key="gsk_test_key", model_name="qwen/qwen3.8-27b")
    assert provider.provider_name == "groq"
    assert provider.supports_streaming is True
    assert provider.supports_tools is True
    assert provider.model_name == "qwen/qwen3.8-27b"

@pytest.mark.anyio
async def test_groq_stt_initialization():
    provider = GroqSTTProvider(api_key="gsk_test_key", model_name="whisper-large-v3-turbo")
    assert provider.provider_name == "groq_stt"
    assert provider.model_name == "whisper-large-v3-turbo"
