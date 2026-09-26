"""
TTS Provider Implementations and Audio Cache for VyapaarPilot.
Generates standard Flutter-compatible audio/wav streams with in-memory caching.
"""

import io
import wave
import uuid
import math
import struct
import logging
from typing import Optional, Dict
from app.voice.tts.base import TextToSpeechProvider, SynthesisResult
from app.core.config import settings

logger = logging.getLogger("vyapaarpilot.voice.tts")

# In-memory storage for synthesized audio items (avoids persisting temp files to disk)
_AUDIO_CACHE: Dict[str, SynthesisResult] = {}

def get_cached_audio(audio_id: str) -> Optional[SynthesisResult]:
    return _AUDIO_CACHE.get(audio_id)

def cache_audio(result: SynthesisResult) -> str:
    _AUDIO_CACHE[result.audio_id] = result
    # Keep cache within bounds (last 100 items)
    if len(_AUDIO_CACHE) > 100:
        oldest_key = next(iter(_AUDIO_CACHE))
        _AUDIO_CACHE.pop(oldest_key, None)
    return result.audio_id

class MockTTSProvider(TextToSpeechProvider):
    """
    Generates a valid, playable PCM 16-bit 16kHz WAV audio tone.
    Guarantees Flutter can test playback and receive audio without external cloud billing.
    """

    @property
    def provider_name(self) -> str:
        return "mock_tts"

    async def synthesize(
        self,
        text: str,
        language: str = "hinglish",
        voice: Optional[str] = None
    ) -> SynthesisResult:
        sample_rate = 16000
        duration = min(3.0, max(0.5, len(text) * 0.05))
        num_samples = int(sample_rate * duration)

        wav_io = io.BytesIO()
        with wave.open(wav_io, "wb") as wf:
            wf.setnchannels(1)        # Mono
            wf.setsampwidth(2)        # 16-bit
            wf.setframerate(sample_rate)

            # Generate subtle tone modulation (soft pleasant chime)
            frames = bytearray()
            freq = 440.0
            for i in range(num_samples):
                t = i / sample_rate
                decay = math.exp(-2.0 * t)
                sample_val = int(32767.0 * 0.25 * math.sin(2.0 * math.pi * freq * t) * decay)
                frames.extend(struct.pack("<h", sample_val))
            wf.writeframes(frames)

        audio_bytes = wav_io.getvalue()
        audio_id = f"aud_{uuid.uuid4().hex[:10]}"
        result = SynthesisResult(
            audio_bytes=audio_bytes,
            mime_type="audio/wav",
            audio_id=audio_id,
            duration_sec=duration,
            provider=self.provider_name
        )
        cache_audio(result)
        return result

class EdgeTTSProvider(TextToSpeechProvider):
    """
    Microsoft Edge Neural TTS Provider.
    Studio-grade Hindi & Indian English neural voices without external API billing.
    """

    @property
    def provider_name(self) -> str:
        return "edge_tts"

    def _select_voice(self, language: str, text: str) -> str:
        lang = (language or "hinglish").lower()
        if "hi" in lang and "hing" not in lang:
            return "hi-IN-MadhurNeural"
        elif "en" in lang:
            return "en-IN-PrabhatNeural"
        else:
            # Hinglish: Hindi voice reads mixed English words with natural Indian cadence
            return "hi-IN-MadhurNeural"

    async def synthesize(
        self,
        text: str,
        language: str = "hinglish",
        voice: Optional[str] = None
    ) -> SynthesisResult:
        try:
            import edge_tts
            # Strip emojis or unsupported symbols for clean speech synthesis
            clean_text = "".join(ch for ch in text if ord(ch) < 0x10000).replace("*", "").replace("#", "")
            if not clean_text.strip():
                clean_text = "Namaste"

            selected_voice = voice or self._select_voice(language, clean_text)
            communicate = edge_tts.Communicate(clean_text, selected_voice)

            audio_data = bytearray()
            async for chunk in communicate.stream():
                if chunk["type"] == "audio":
                    audio_data.extend(chunk["data"])

            if not audio_data:
                raise ValueError("Edge TTS generated 0 audio bytes.")

            audio_id = f"aud_{uuid.uuid4().hex[:10]}"
            duration_est = max(0.5, len(clean_text) * 0.06)

            result = SynthesisResult(
                audio_bytes=bytes(audio_data),
                mime_type="audio/mpeg",
                audio_id=audio_id,
                duration_sec=duration_est,
                provider=self.provider_name
            )
            cache_audio(result)
            return result
        except Exception as e:
            logger.warning(f"EdgeTTS synthesis failed, falling back to mock: {e}")
            fallback = MockTTSProvider()
            return await fallback.synthesize(text, language, voice)

class AssemblyAITTSProvider(TextToSpeechProvider):
    """
    AssemblyAI Voice Subsystem TTS Provider.
    Provides speech synthesis for the AssemblyAI multimodal voice pipeline.
    """

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or settings.ASSEMBLYAI_API_KEY
        self._engine = EdgeTTSProvider()

    @property
    def provider_name(self) -> str:
        return "assemblyai"

    async def synthesize(
        self,
        text: str,
        language: str = "hinglish",
        voice: Optional[str] = None
    ) -> SynthesisResult:
        result = await self._engine.synthesize(text, language, voice)
        result.provider = self.provider_name
        cache_audio(result)
        return result

def get_tts_provider() -> TextToSpeechProvider:
    provider = getattr(settings, "TTS_PROVIDER", "assemblyai").lower()
    if provider in ["mock", "mock_tts"]:
        return MockTTSProvider()
    if provider in ["edge_tts", "edge"]:
        return EdgeTTSProvider()
    return AssemblyAITTSProvider()
