"""
Speech-To-Text (STT) Provider Abstraction for VyapaarPilot.
Allows pluggable audio transcription providers (Gemini multimodal, Whisper, Cloud Speech, Mock).
"""

from abc import ABC, abstractmethod
from typing import Optional
from pydantic import BaseModel

class TranscriptionResult(BaseModel):
    transcript: str
    detected_language: str = "hi"
    confidence: float = 0.95
    duration_sec: Optional[float] = None
    provider: str = "stt"

class SpeechToTextProvider(ABC):

    @property
    @abstractmethod
    def provider_name(self) -> str:
        pass

    @abstractmethod
    async def transcribe(
        self,
        audio_bytes: bytes,
        mime_type: str,
        language_hint: Optional[str] = None
    ) -> TranscriptionResult:
        """Transcribes raw audio bytes into normalized text."""
        pass
