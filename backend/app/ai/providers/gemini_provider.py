"""
Gemini AI Provider implementation for VyapaarPilot.
Uses the official Google GenAI SDK.
"""

import logging
from typing import Optional
from app.ai.base import AIProvider, AICompletionRequest, AICompletionResponse
from app.core.config import settings

logger = logging.getLogger("vyapaarpilot.ai.gemini")

class GeminiProvider(AIProvider):

    def __init__(self, api_key: Optional[str] = None, model_name: str = "gemini-2.5-flash"):
        self.api_key = api_key or settings.GEMINI_API_KEY
        self.model_name = model_name
        self.client = None
        if self.api_key:
            try:
                from google import genai
                self.client = genai.Client(api_key=self.api_key)
            except Exception as e:
                logger.warning(f"Could not initialize GenAI Client: {e}")

    @property
    def provider_name(self) -> str:
        return "gemini"

    @property
    def supports_streaming(self) -> bool:
        return True

    @property
    def supports_tools(self) -> bool:
        return True

    async def generate_response(self, request: AICompletionRequest) -> AICompletionResponse:
        """Async generation via thread execution or GenAI client."""
        return self.generate_response_sync(request)

    def generate_response_sync(self, request: AICompletionRequest) -> AICompletionResponse:
        if not self.client:
            raise RuntimeError("Gemini API key is not configured.")

        try:
            full_prompt = request.prompt
            if request.system_instruction:
                full_prompt = f"{request.system_instruction}\n\n{request.prompt}"

            response = self.client.models.generate_content(
                model=self.model_name,
                contents=full_prompt,
            )

            text_output = response.text.strip() if hasattr(response, "text") and response.text else ""
            return AICompletionResponse(
                text=text_output,
                provider=self.provider_name,
                model_name=self.model_name,
                raw_response=response
            )
        except Exception as e:
            logger.error(f"Gemini generation error: {e}")
            raise
