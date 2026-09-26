"""
Groq AI Provider implementation for VyapaarPilot.
High-speed LLM inference via Groq's OpenAI-compatible completions API.
"""

import logging
from typing import Optional, Dict, Any
import httpx
from app.ai.base import AIProvider, AICompletionRequest, AICompletionResponse
from app.core.config import settings

logger = logging.getLogger("vyapaarpilot.ai.groq")

class GroqProvider(AIProvider):
    """
    Groq AI Provider supporting high-speed inference for LLaMA 3, Qwen, etc.
    """

    def __init__(self, api_key: Optional[str] = None, model_name: Optional[str] = None):
        self.api_key = api_key or settings.GROQ_API_KEY
        self.model_name = model_name or settings.GROQ_MODEL or "qwen/qwen3.8-27b"
        self.endpoint = "https://api.groq.com/openai/v1/chat/completions"

    @property
    def provider_name(self) -> str:
        return "groq"

    @property
    def supports_streaming(self) -> bool:
        return True

    @property
    def supports_tools(self) -> bool:
        return True

    def _build_payload(self, request: AICompletionRequest) -> Dict[str, Any]:
        messages = []
        if request.system_instruction:
            messages.append({"role": "system", "content": request.system_instruction})
        messages.append({"role": "user", "content": request.prompt})

        return {
            "model": self.model_name,
            "messages": messages,
            "temperature": request.temperature,
            "max_tokens": request.max_tokens or 1024
        }

    async def generate_response(self, request: AICompletionRequest) -> AICompletionResponse:
        """Asynchronous generation via httpx AsyncClient."""
        if not self.api_key:
            raise RuntimeError("Groq API key is not configured.")

        payload = self._build_payload(request)
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }

        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                res = await client.post(self.endpoint, json=payload, headers=headers)
                res.raise_for_status()
                data = res.json()

            text_output = ""
            choices = data.get("choices", [])
            if choices and "message" in choices[0]:
                text_output = choices[0]["message"].get("content", "").strip()

            usage = data.get("usage", {})
            return AICompletionResponse(
                text=text_output,
                provider=self.provider_name,
                model_name=self.model_name,
                finish_reason=choices[0].get("finish_reason", "stop") if choices else "stop",
                usage={"total_tokens": usage.get("total_tokens", 0)},
                raw_response=data
            )
        except Exception as e:
            logger.error(f"Groq async generation error: {e}")
            raise

    def generate_response_sync(self, request: AICompletionRequest) -> AICompletionResponse:
        """Synchronous fallback generation."""
        if not self.api_key:
            raise RuntimeError("Groq API key is not configured.")

        payload = self._build_payload(request)
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }

        try:
            with httpx.Client(timeout=30.0) as client:
                res = client.post(self.endpoint, json=payload, headers=headers)
                res.raise_for_status()
                data = res.json()

            text_output = ""
            choices = data.get("choices", [])
            if choices and "message" in choices[0]:
                text_output = choices[0]["message"].get("content", "").strip()

            usage = data.get("usage", {})
            return AICompletionResponse(
                text=text_output,
                provider=self.provider_name,
                model_name=self.model_name,
                finish_reason=choices[0].get("finish_reason", "stop") if choices else "stop",
                usage={"total_tokens": usage.get("total_tokens", 0)},
                raw_response=data
            )
        except Exception as e:
            logger.error(f"Groq sync generation error: {e}")
            raise
