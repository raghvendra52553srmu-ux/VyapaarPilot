"""
STT Provider Implementations for VyapaarPilot.
Supports Gemini Multimodal Audio transcription and Mock offline transcription.
"""

import logging
from typing import Optional
from app.voice.stt.base import SpeechToTextProvider, TranscriptionResult
from app.core.config import settings

logger = logging.getLogger("vyapaarpilot.voice.stt")

class GeminiSTTProvider(SpeechToTextProvider):

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or settings.GEMINI_API_KEY
        self.client = None
        if self.api_key:
            try:
                from google import genai
                self.client = genai.Client(api_key=self.api_key)
            except Exception as e:
                logger.warning(f"Could not initialize GenAI for STT: {e}")

    @property
    def provider_name(self) -> str:
        return "gemini_stt"

    async def transcribe(
        self,
        audio_bytes: bytes,
        mime_type: str,
        language_hint: Optional[str] = None
    ) -> TranscriptionResult:
        if not self.client:
            raise RuntimeError("Gemini STT requires GEMINI_API_KEY.")

        try:
            from google.genai import types
            
            clean_mime = (mime_type or "audio/wav").split(";")[0].strip().lower()
            if clean_mime == "application/octet-stream":
                clean_mime = "audio/wav"

            prompt = (
                "Listen carefully to this audio recording of an Indian small shopkeeper speaking in Hindi, Hinglish, or English. "
                "Provide an exact, verbatim transcript of what they said. Do not add explanations or formatting. Only return the transcript text."
            )

            part = types.Part.from_bytes(data=audio_bytes, mime_type=clean_mime)
            response = self.client.models.generate_content(
                model="gemini-2.5-flash",
                contents=[part, prompt]
            )

            transcript = response.text.strip() if hasattr(response, "text") and response.text else ""
            from app.voice.audio.normalizer import normalize_transcript, detect_language_from_text
            clean_txt = normalize_transcript(transcript)
            lang = detect_language_from_text(clean_txt)

            return TranscriptionResult(
                transcript=clean_txt,
                detected_language=lang,
                confidence=0.92,
                provider=self.provider_name
            )
        except Exception as e:
            logger.error(f"Gemini STT transcription failed: {e}")
            raise

class MockSTTProvider(SpeechToTextProvider):

    @property
    def provider_name(self) -> str:
        return "mock_stt"

    async def transcribe(
        self,
        audio_bytes: bytes,
        mime_type: str,
        language_hint: Optional[str] = None
    ) -> TranscriptionResult:
        hint = (language_hint or "hinglish").lower()
        if "hi" in hint and "hing" not in hint:
            t = "मेरी मंगलवार शाम की बिक्री क्यों कम हो रही है?"
            lang = "hi"
        elif "en" in hint:
            t = "Why are my Tuesday evening sales declining?"
            lang = "en"
        else:
            t = "Bhai Tuesday evening mein meri sales kyun gir rahi hai?"
            lang = "hinglish"

        return TranscriptionResult(
            transcript=t,
            detected_language=lang,
            confidence=0.98,
            provider=self.provider_name
        )

class GroqSTTProvider(SpeechToTextProvider):
    """
    Groq Whisper STT Provider.
    Blazing fast sub-second transcription using Whisper-large-v3-turbo on Groq LPU.
    """

    def __init__(self, api_key: Optional[str] = None, model_name: Optional[str] = None):
        self.api_key = api_key or settings.GROQ_API_KEY
        self.model_name = model_name or settings.GROQ_STT_MODEL or "whisper-large-v3-turbo"
        self.endpoint = "https://api.groq.com/openai/v1/audio/transcriptions"

    @property
    def provider_name(self) -> str:
        return "groq_stt"

    async def transcribe(
        self,
        audio_bytes: bytes,
        mime_type: str,
        language_hint: Optional[str] = None
    ) -> TranscriptionResult:
        if not self.api_key:
            raise RuntimeError("Groq STT requires GROQ_API_KEY.")

        import httpx
        from app.voice.audio.normalizer import normalize_transcript, detect_language_from_text

        clean_mime = (mime_type or "audio/wav").split(";")[0].strip().lower()
        if clean_mime == "application/octet-stream":
            clean_mime = "audio/wav"

        # Determine extension
        ext = "wav"
        if "mp4" in clean_mime or "m4a" in clean_mime:
            ext = "m4a"
        elif "mp3" in clean_mime or "mpeg" in clean_mime:
            ext = "mp3"
        elif "webm" in clean_mime:
            ext = "webm"
        elif "aac" in clean_mime:
            ext = "aac"

        filename = f"audio.{ext}"
        headers = {"Authorization": f"Bearer {self.api_key}"}
        
        data = {
            "model": self.model_name,
            "response_format": "json"
        }
        if language_hint:
            h = language_hint.lower()
            if "hi" in h and "hing" not in h:
                data["language"] = "hi"
            elif "en" in h:
                data["language"] = "en"

        files = {
            "file": (filename, audio_bytes, clean_mime)
        }

        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                res = await client.post(self.endpoint, headers=headers, data=data, files=files)
                res.raise_for_status()
                res_data = res.json()

            raw_text = res_data.get("text", "").strip()
            clean_txt = normalize_transcript(raw_text)
            lang = detect_language_from_text(clean_txt)

            return TranscriptionResult(
                transcript=clean_txt,
                detected_language=lang,
                confidence=0.96,
                provider=self.provider_name
            )
        except Exception as e:
            logger.error(f"Groq STT transcription failed: {e}")
            raise

def get_stt_provider() -> SpeechToTextProvider:
    provider_name = getattr(settings, "STT_PROVIDER", "groq").lower()

    if (provider_name == "groq" or not settings.GEMINI_API_KEY) and settings.GROQ_API_KEY:
        try:
            return GroqSTTProvider()
        except Exception:
            pass

    if provider_name == "gemini" and settings.GEMINI_API_KEY:
        try:
            return GeminiSTTProvider()
        except Exception:
            pass

    return MockSTTProvider()
