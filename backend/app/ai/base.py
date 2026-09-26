"""
Provider-Independent AI Abstractions for VyapaarPilot.
Defines interfaces and domain models for AI model providers.
"""

from abc import ABC, abstractmethod
from typing import Dict, Any, Optional, List
from pydantic import BaseModel, Field

class AICompletionRequest(BaseModel):
    prompt: str
    system_instruction: Optional[str] = None
    structured_context: Optional[Dict[str, Any]] = None
    language: str = "hinglish"
    temperature: float = 0.2
    max_tokens: Optional[int] = 1024

class AICompletionResponse(BaseModel):
    text: str
    provider: str
    model_name: str
    finish_reason: Optional[str] = "stop"
    usage: Optional[Dict[str, int]] = None
    raw_response: Optional[Any] = None

class AIProvider(ABC):
    """
    Abstract AI Provider Interface.
    Allows replacing Gemini with Claude, OpenAI, Local models, or Mock providers
    without modifying business or agent orchestration logic.
    """

    @property
    @abstractmethod
    def provider_name(self) -> str:
        """Name of the provider (e.g. 'gemini', 'mock')."""
        pass

    @property
    @abstractmethod
    def supports_streaming(self) -> bool:
        """Whether this provider supports streaming token deltas."""
        pass

    @property
    @abstractmethod
    def supports_tools(self) -> bool:
        """Whether this provider supports native tool/function calling."""
        pass

    @abstractmethod
    async def generate_response(self, request: AICompletionRequest) -> AICompletionResponse:
        """Generates a conversational text response based on structured context."""
        pass

    @abstractmethod
    def generate_response_sync(self, request: AICompletionRequest) -> AICompletionResponse:
        """Synchronous response generation helper."""
        pass
