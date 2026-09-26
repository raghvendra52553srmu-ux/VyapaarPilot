"""
Lightweight Conversation State Manager for VyapaarPilot.
Tracks conversation threads, message histories, and active context across turns.
Thread-safe in-memory storage for high performance and zero Redis overhead during hackathon.
"""

import uuid
from datetime import datetime, timezone
from typing import Dict, List, Optional, Any
from pydantic import BaseModel, Field

class ConversationMessage(BaseModel):
    message_id: str = Field(default_factory=lambda: f"msg_{uuid.uuid4().hex[:8]}")
    conversation_id: str
    role: str = "user"  # "user" or "assistant"
    input_type: str = "text"  # "text" or "voice"
    text: str
    intent: Optional[str] = None
    tool_calls: Optional[List[Dict[str, Any]]] = None
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

class ConversationSession(BaseModel):
    conversation_id: str = Field(default_factory=lambda: f"conv_{uuid.uuid4().hex[:8]}")
    merchant_id: str
    language: str = "hinglish"
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    messages: List[ConversationMessage] = []
    metadata: Dict[str, Any] = {}

class ConversationManager:

    def __init__(self):
        self._sessions: Dict[str, ConversationSession] = {}

    def get_or_create(
        self,
        conversation_id: Optional[str],
        merchant_id: str,
        language: str = "hinglish"
    ) -> ConversationSession:
        if conversation_id and conversation_id in self._sessions:
            session = self._sessions[conversation_id]
            session.updated_at = datetime.now(timezone.utc)
            return session

        new_id = conversation_id or f"conv_{uuid.uuid4().hex[:8]}"
        session = ConversationSession(
            conversation_id=new_id,
            merchant_id=merchant_id,
            language=language
        )
        self._sessions[new_id] = session
        return session

    def add_message(
        self,
        conversation_id: str,
        role: str,
        text: str,
        input_type: str = "text",
        intent: Optional[str] = None,
        tool_calls: Optional[List[Dict[str, Any]]] = None
    ) -> ConversationMessage:
        if conversation_id not in self._sessions:
            return None

        msg = ConversationMessage(
            conversation_id=conversation_id,
            role=role,
            input_type=input_type,
            text=text,
            intent=intent,
            tool_calls=tool_calls
        )
        self._sessions[conversation_id].messages.append(msg)
        self._sessions[conversation_id].updated_at = datetime.now(timezone.utc)
        return msg

    def get_history(self, conversation_id: str, limit: int = 10) -> List[ConversationMessage]:
        if conversation_id not in self._sessions:
            return []
        return self._sessions[conversation_id].messages[-limit:]

conversation_manager = ConversationManager()
