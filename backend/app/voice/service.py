"""
Unified Voice Service for VyapaarPilot.
Coordinates:
1. Audio validation
2. Speech-to-Text transcription
3. UNIFIED Agent Orchestrator execution (same brain as text)
4. Optional Text-To-Speech synthesis with non-blocking error resilience
"""

import logging
from typing import Dict, Any, Optional
from sqlalchemy.orm import Session

from app.voice.audio.validator import validate_audio_file
from app.voice.stt.provider import get_stt_provider
from app.voice.tts.provider import get_tts_provider
from app.agents.orchestrator import agent_orchestrator
from app.schemas.ai import UnifiedConversationResponse, AudioMeta

logger = logging.getLogger("vyapaarpilot.voice.service")

class VoiceService:

    async def process_voice_turn(
        self,
        db: Session,
        merchant_id: str,
        audio_bytes: bytes,
        mime_type: str,
        language: Optional[str] = "hinglish",
        conversation_id: Optional[str] = None,
        response_mode: str = "text"
    ) -> Dict[str, Any]:
        """
        Processes voice turn:
        Audio -> Validate -> STT -> Unified Agent Orchestrator -> Optional TTS -> Unified Response.
        """
        # 1. Validate Audio
        is_valid, err_code, err_msg = validate_audio_file(audio_bytes, mime_type)
        if not is_valid:
            return {
                "error": {
                    "code": err_code,
                    "message": err_msg,
                    "retryable": False,
                    "details": {"mime_type": mime_type, "size_bytes": len(audio_bytes)}
                }
            }

        # 2. Transcribe Audio (STT)
        logger.info(f"🎤 Voice turn received: {len(audio_bytes)} bytes, MIME='{mime_type}', hint='{language}', merchant={merchant_id}")
        stt_provider = get_stt_provider()
        try:
            stt_result = await stt_provider.transcribe(
                audio_bytes=audio_bytes,
                mime_type=mime_type,
                language_hint=language
            )
        except Exception as e:
            logger.error(f"STT transcription failed: {e}")
            return {
                "error": {
                    "code": "VOICE_TRANSCRIPTION_FAILED",
                    "message": "Could not understand the recording. Please speak clearly and try again.",
                    "retryable": True,
                    "details": str(e)
                }
            }

        transcript = (stt_result.transcript or "").strip()
        detected_lang = stt_result.detected_language or language or "hi"
        effective_lang = language or detected_lang or "hinglish"

        # If user audio was silence/inaudible, do NOT call LLM with fake text
        if not transcript:
            logger.warning(f"Voice turn produced empty transcript from {len(audio_bytes)} bytes audio.")
            no_speech_text = (
                "Aapki aawaz theek se sunai nahi di. Kripya microphone ke paas aakar dobara bolein."
                if "hi" in effective_lang.lower() or "hing" in effective_lang.lower()
                else "I couldn't hear any speech clearly. Please speak into your microphone and try again."
            )
            empty_audio_info = None
            if response_mode in ("audio", "both"):
                try:
                    tts_provider = get_tts_provider()
                    synth_res = await tts_provider.synthesize(text=no_speech_text, language=effective_lang)
                    empty_audio_info = AudioMeta(
                        audio_available=True,
                        audio_url=f"/api/ai/voice/audio/{synth_res.audio_id}",
                        audio_id=synth_res.audio_id,
                        mime_type=synth_res.mime_type,
                        duration_sec=synth_res.duration_sec,
                        provider=synth_res.provider
                    ).model_dump()
                except Exception as tts_err:
                    logger.warning(f"TTS for empty voice warning failed: {tts_err}")

            return {
                "conversation_id": conversation_id,
                "message_id": f"msg_empty_{merchant_id}",
                "input": {
                    "type": "voice",
                    "transcript": "",
                    "detected_language": effective_lang
                },
                "intent": "CLARIFICATION",
                "confidence": 1.0,
                "response": {
                    "text": no_speech_text,
                    "language": effective_lang,
                    "suggestions": [
                        "Aaj ki sales kaisi rahi?",
                        "Meri sales mein kya opportunity hai?",
                        "Stock kab reorder karna hai?"
                    ]
                },
                "audio": empty_audio_info,
                "data": {},
                "actions": [],
                "warnings": []
            }

        logger.info(f"🗣️ User spoken input transcribed: '{transcript}' (lang: {effective_lang})")

        # 3. Call SAME Agent Orchestrator as text conversations
        agent_res = await agent_orchestrator.handle_conversation_turn(
            db=db,
            merchant_id=merchant_id,
            user_input=transcript,
            input_type="voice",
            language=effective_lang,
            conversation_id=conversation_id
        )

        # 4. Optional Text-To-Speech (TTS)
        audio_info = None
        if response_mode in ("audio", "both"):
            try:
                tts_provider = get_tts_provider()
                synth_res = await tts_provider.synthesize(
                    text=agent_res.response.text,
                    language=agent_res.response.language
                )
                audio_info = AudioMeta(
                    audio_available=True,
                    audio_url=f"/api/ai/voice/audio/{synth_res.audio_id}",
                    audio_id=synth_res.audio_id,
                    mime_type=synth_res.mime_type,
                    duration_sec=synth_res.duration_sec,
                    provider=synth_res.provider
                )
            except Exception as e:
                logger.warning(f"TTS synthesis failed, falling back to text: {e}")
                audio_info = AudioMeta(
                    audio_available=False,
                    audio_url=None,
                    error_message=f"TTS synthesis temporarily unavailable: {e}"
                )

        # Attach audio info to response if generated
        res_dict = agent_res.model_dump()
        if audio_info:
            res_dict["audio"] = audio_info.model_dump()

        # Update input block with voice specifics
        res_dict["input"] = {
            "type": "voice",
            "transcript": transcript,
            "detected_language": detected_lang
        }

        return res_dict

voice_service = VoiceService()
