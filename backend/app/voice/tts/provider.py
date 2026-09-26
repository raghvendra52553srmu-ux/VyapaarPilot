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

def get_tts_provider() -> TextToSpeechProvider:
    # Pluggable: can be switched to gTTS, ElevenLabs, Azure, or Mock
    return MockTTSProvider()
