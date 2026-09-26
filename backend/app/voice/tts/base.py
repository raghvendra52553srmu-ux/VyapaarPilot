"""
Text-To-Speech (TTS) Provider Abstraction for VyapaarPilot.
Allows pluggable audio synthesis providers (Google GenAI Audio, gTTS, EdgeTTS, Mock).
"""

from abc import ABC, abstractmethod
from typing import Optional
from pydantic import BaseModel

class SynthesisResult(BaseModel):
    audio_bytes: bytes
    mime_type: str = "audio/wav"
    audio_id: str
    duration_sec: Optional[float] = None
    provider: str = "tts"

class TextToSpeechProvider(ABC):

    @property
    @abstractmethod
    def provider_name(self) -> str:
        pass

    @abstractmethod
    async def synthesize(
        self,
        text: str,
        language: str = "hinglish",
        voice: Optional[str] = None
    ) -> SynthesisResult:
        """Synthesizes text into audio bytes."""
        pass
