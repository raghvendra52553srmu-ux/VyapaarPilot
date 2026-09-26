"""
Unified AI and Conversational Schemas for VyapaarPilot.
Adheres strictly to the Flutter-First Unified Contract.
"""

from pydantic import BaseModel, Field, model_validator
from typing import List, Optional, Dict, Any
from app.agents.actions import ActionPayload

class AIAskRequest(BaseModel):
    merchant_id: str = Field(..., min_length=1, max_length=50)
    message: Optional[str] = Field(None, max_length=1000)
    question: Optional[str] = Field(None, max_length=1000) # Backward compatibility
    language: Optional[str] = Field("hinglish", description="Language: 'hi', 'en', or 'hinglish'")
    conversation_id: Optional[str] = Field(None, description="Optional conversation session ID")
    response_mode: Optional[str] = Field("text", description="'text', 'audio', or 'both'")

    @model_validator(mode="before")
    @classmethod
    def unify_question_message(cls, data: Any) -> Any:
        if isinstance(data, dict):
            if not data.get("message") and data.get("question"):
                data["message"] = data["question"]
            elif not data.get("question") and data.get("message"):
                data["question"] = data["message"]
        return data

class InputMeta(BaseModel):
    type: str = "text"  # "text" or "voice"
    transcript: str
    detected_language: Optional[str] = "hinglish"

class ResponseMeta(BaseModel):
    text: str
    language: str = "hinglish"

class AudioMeta(BaseModel):
    audio_available: bool = False
    audio_url: Optional[str] = None
    audio_id: Optional[str] = None
    mime_type: Optional[str] = "audio/wav"
    duration_sec: Optional[float] = None
    error_message: Optional[str] = None

class UnifiedConversationResponse(BaseModel):
    conversation_id: str
    message_id: str
    input: InputMeta
    response: ResponseMeta
    # Backward compatibility with existing frontend endpoints
    answer: str
    intent: Optional[str] = "ANALYTICS_QUERY"
    evidence: List[Dict[str, Any]] = []
    data_used: List[str] = []
    actions: List[ActionPayload] = []
    # Backward compatibility with existing UI
    suggested_actions: List[str] = []
    audio: Optional[AudioMeta] = None
    metadata: Dict[str, Any] = Field(default_factory=dict)

# Alias for backward compatibility
AIAskResponse = UnifiedConversationResponse

class ActionExecuteRequest(BaseModel):
    action_id: str
    merchant_id: Optional[str] = None
    tool: Optional[str] = None
    arguments: Optional[Dict[str, Any]] = {}
    confirmed: bool = True

class ActionExecuteResponse(BaseModel):
    success: bool = True
    action_id: str
    tool: str
    status: str = "success"
    result: Dict[str, Any]
    message: str

class CapabilitiesResponse(BaseModel):
    text_chat: bool = True
    voice_input: bool = True
    voice_output: bool = True
    realtime: bool = True
    languages: List[str] = ["en", "hi", "hinglish"]
    audio_formats: List[str] = [
        "audio/wav",
        "audio/mpeg",
        "audio/mp4",
        "audio/aac",
        "audio/webm",
        "audio/ogg"
    ]
    tools_available: List[str] = [
        "get_merchant_summary",
        "get_sales_trends",
        "get_customer_analytics",
        "get_opportunities",
        "get_opportunity_details",
        "get_recommendation",
        "get_experiment_result",
        "create_experiment"
    ]

class ErrorDetail(BaseModel):
    code: str
    message: str
    retryable: bool = False
    details: Optional[Any] = None

class ErrorResponse(BaseModel):
    error: ErrorDetail
