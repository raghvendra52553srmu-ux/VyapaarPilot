"""
Unified Multimodal AI and Voice Routes for VyapaarPilot.
Exposes:
1. POST /api/ai/ask (Evolved unified text chat contract)
2. POST /api/ai/voice (Multipart voice turn processing with STT & optional TTS)
3. GET  /api/ai/voice/audio/{audio_id} (Binary streaming of synthesized audio)
4. POST /api/ai/action/execute (Safe execution of confirmed merchant actions)
5. GET  /api/capabilities (Dynamic feature discovery for Flutter)
6. WS   /api/ai/realtime/{merchant_id} (WebSocket realtime conversational protocol)
"""

import json
import base64
import logging
from typing import Optional
from fastapi import (
    APIRouter, Depends, UploadFile, File, Form, HTTPException, status,
    WebSocket, WebSocketDisconnect, Response
)
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from app.core.database import get_db, SessionLocal
from app.schemas.ai import (
    AIAskRequest, UnifiedConversationResponse,
    ActionExecuteRequest, ActionExecuteResponse, CapabilitiesResponse
)
from app.agents.orchestrator import agent_orchestrator
from app.agents.actions import tool_registry
from app.voice.service import voice_service
from app.voice.tts.provider import get_cached_audio

logger = logging.getLogger("vyapaarpilot.routes.ai")

router = APIRouter(tags=["AI Multimodal Assistant"])

# ============================================================================
# 1. Capabilities Discovery (Part 12)
# ============================================================================
@router.get("/capabilities", response_model=CapabilitiesResponse)
def get_capabilities():
    """
    Returns supported assistant capabilities, input types, and audio formats.
    Used by Flutter to dynamically activate UI features (microphone, streaming, etc.).
    """
    return CapabilitiesResponse()

# ============================================================================
# 2. Unified Text Conversational Endpoint (Part 4)
# ============================================================================
@router.post("/ai/ask", response_model=UnifiedConversationResponse)
async def ask_ai(request: AIAskRequest, db: Session = Depends(get_db)):
    """
    Unified text conversation endpoint.
    Maintains backward compatibility while returning structured actions, evidence, and session info.
    """
    user_msg = request.message or request.question
    if not user_msg:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Either 'message' or 'question' field must be provided."
        )

    res = await agent_orchestrator.handle_conversation_turn(
        db=db,
        merchant_id=request.merchant_id,
        user_input=user_msg,
        input_type="text",
        language=request.language or "hinglish",
        conversation_id=request.conversation_id
    )
    return res

# ============================================================================
# 3. Voice Input Endpoint (Part 5)
# ============================================================================
@router.post("/ai/voice", response_model=UnifiedConversationResponse)
async def process_voice(
    merchant_id: str = Form(...),
    audio: UploadFile = File(...),
    language: Optional[str] = Form("hinglish"),
    conversation_id: Optional[str] = Form(None),
    response_mode: Optional[str] = Form("text"),
    db: Session = Depends(get_db)
):
    """
    Multipart voice turn endpoint for Flutter.
    Audio bytes -> Validation -> STT -> Same Agent Brain -> Grounded Response -> Optional TTS.
    """
    content = await audio.read()
    mime = audio.content_type or "audio/wav"

    res = await voice_service.process_voice_turn(
        db=db,
        merchant_id=merchant_id,
        audio_bytes=content,
        mime_type=mime,
        language=language,
        conversation_id=conversation_id,
        response_mode=response_mode
    )

    if "error" in res:
        err = res["error"]
        status_code = status.HTTP_400_BAD_REQUEST
        if err["code"] == "AUDIO_TOO_LARGE":
            status_code = status.HTTP_413_REQUEST_ENTITY_TOO_LARGE
        return JSONResponse(status_code=status_code, content=res)

    return res

# ============================================================================
# 4. Binary Audio Streaming Endpoint
# ============================================================================
@router.get("/ai/voice/audio/{audio_id}")
def stream_audio(audio_id: str):
    """
    Streams synthesized WAV audio bytes directly to the Flutter audio player.
    """
    cached = get_cached_audio(audio_id)
    if not cached:
        raise HTTPException(status_code=404, detail="Audio resource expired or not found.")

    return Response(
        content=cached.audio_bytes,
        media_type=cached.mime_type,
        headers={
            "Content-Disposition": f"inline; filename={audio_id}.wav",
            "Cache-Control": "public, max-age=3600"
        }
    )

# ============================================================================
# 5. Safe Action Confirmation Execution (Part 7 & 8)
# ============================================================================
@router.post("/ai/action/execute")
def execute_confirmed_action(request: ActionExecuteRequest, db: Session = Depends(get_db)):
    """
    Executes a merchant-approved write action (e.g. launching an experiment).
    Enforces that write actions cannot be triggered directly by LLMs without explicit merchant approval.
    """
    if not request.confirmed:
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={
                "error": {
                    "code": "TOOL_CONFIRMATION_REQUIRED",
                    "message": "This action requires explicit merchant confirmation before execution.",
                    "retryable": False,
                    "details": {"action_id": request.action_id, "tool": request.tool}
                }
            }
        )

    if request.tool and request.tool not in tool_registry._tools:
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={
                "error": {
                    "code": "TOOL_VALIDATION_FAILED",
                    "message": f"Unknown tool '{request.tool}'.",
                    "retryable": False,
                    "details": {"tool": request.tool}
                }
            }
        )

    try:
        execution = tool_registry.execute_confirmed_action(
            action_id=request.action_id,
            db=db,
            override_arguments=request.arguments,
            tool=request.tool
        )
        return ActionExecuteResponse(
            action_id=request.action_id,
            tool=execution["tool"],
            status="success",
            result=execution["result"],
            message=f"Action '{execution['tool']}' was successfully executed."
        )
    except KeyError as e:
        return JSONResponse(
            status_code=status.HTTP_404_NOT_FOUND,
            content={
                "error": {
                    "code": "ACTION_NOT_FOUND",
                    "message": str(e),
                    "retryable": False
                }
            }
        )
    except Exception as e:
        logger.error(f"Action execution error: {e}")
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={
                "error": {
                    "code": "TOOL_EXECUTION_FAILED",
                    "message": f"Action execution failed: {e}",
                    "retryable": False
                }
            }
        )

# ============================================================================
# 6. Realtime WebSocket Protocol (Part 6)
# ============================================================================
@router.websocket("/ai/realtime/{merchant_id}")
async def realtime_voice_ws(websocket: WebSocket, merchant_id: str):
    """
    WebSocket endpoint for realtime audio and text streaming.
    Protocol:
    Flutter -> Backend: session.start, audio.chunk, audio.commit, text.message, action.confirm
    Backend -> Flutter: session.ready, transcript.final, agent.thinking, tool.started,
                        response.text.delta, response.text.done, response.done, error
    """
    await websocket.accept()
    session_lang = "hinglish"
    audio_buffer = bytearray()
    db = SessionLocal()

    try:
        # Await session start
        init_data = await websocket.receive_text()
        init_event = json.loads(init_data)
        if init_event.get("type") == "session.start":
            session_lang = init_event.get("language", "hinglish")
            await websocket.send_json({
                "type": "session.ready",
                "merchant_id": merchant_id,
                "language": session_lang
            })
        else:
            await websocket.send_json({
                "type": "error",
                "code": "PROTOCOL_ERROR",
                "message": "Expected 'session.start' event."
            })
            await websocket.close()
            return

        while True:
            msg_text = await websocket.receive_text()
            event = json.loads(msg_text)
            event_type = event.get("type")

            # A. Audio Streaming Chunk
            if event_type == "audio.chunk":
                chunk_b64 = event.get("audio", "")
                if chunk_b64:
                    audio_buffer.extend(base64.b64decode(chunk_b64))

            # B. Audio Commit (End of speaking turn)
            elif event_type == "audio.commit":
                if not audio_buffer:
                    await websocket.send_json({
                        "type": "error",
                        "code": "EMPTY_AUDIO",
                        "message": "No audio received in buffer."
                    })
                    continue

                await websocket.send_json({"type": "agent.thinking"})

                # Transcribe
                res = await voice_service.process_voice_turn(
                    db=db,
                    merchant_id=merchant_id,
                    audio_bytes=bytes(audio_buffer),
                    mime_type="audio/wav",
                    language=session_lang,
                    response_mode="both"
                )
                audio_buffer.clear()

                if "error" in res:
                    await websocket.send_json({
                        "type": "error",
                        "code": res["error"]["code"],
                        "message": res["error"]["message"]
                    })
                    continue

                # Stream final transcript
                await websocket.send_json({
                    "type": "transcript.final",
                    "text": res["input"]["transcript"]
                })

                # Stream response delta
                full_text = res["response"]["text"]
                words = full_text.split()
                for i in range(0, len(words), 3):
                    chunk = " ".join(words[i:i+3]) + " "
                    await websocket.send_json({
                        "type": "response.text.delta",
                        "text": chunk
                    })

                await websocket.send_json({
                    "type": "response.text.done",
                    "text": full_text
                })

                await websocket.send_json({
                    "type": "response.done",
                    "payload": res
                })

            # C. Text Message in WebSocket
            elif event_type == "text.message":
                text = event.get("text", "")
                await websocket.send_json({"type": "agent.thinking"})

                agent_res = await agent_orchestrator.handle_conversation_turn(
                    db=db,
                    merchant_id=merchant_id,
                    user_input=text,
                    input_type="text",
                    language=session_lang
                )

                full_text = agent_res.response.text
                await websocket.send_json({
                    "type": "response.text.done",
                    "text": full_text
                })
                await websocket.send_json({
                    "type": "response.done",
                    "payload": agent_res.model_dump()
                })

            # D. Action Confirmation in WebSocket
            elif event_type == "action.confirm":
                action_id = event.get("action_id")
                args = event.get("arguments", {})
                try:
                    result = tool_registry.execute_confirmed_action(action_id, db, args)
                    await websocket.send_json({
                        "type": "action.executed",
                        "payload": result
                    })
                except Exception as e:
                    await websocket.send_json({
                        "type": "error",
                        "code": "ACTION_FAILED",
                        "message": str(e)
                    })

            elif event_type == "response.cancel":
                audio_buffer.clear()
                await websocket.send_json({"type": "response.cancelled"})

    except WebSocketDisconnect:
        logger.info(f"WebSocket client disconnected for merchant {merchant_id}")
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        try:
            await websocket.send_json({
                "type": "error",
                "code": "INTERNAL_ERROR",
                "message": str(e)
            })
        except Exception:
            pass
    finally:
        db.close()
