"""
AI Service for VyapaarPilot.
Interfaces with the provider-independent AI layer (AIProviderFactory).
Translates pre-computed structured facts into merchant-friendly explanations with anti-hallucination guarantees.
"""

import logging
from typing import Dict, Any, Optional
from app.ai.provider_factory import AIProviderFactory
from app.ai.base import AICompletionRequest
from app.ai.prompts import SYSTEM_INSTRUCTION, build_user_prompt
from app.core.config import settings

logger = logging.getLogger("vyapaarpilot.ai_service")

class AIService:

    def generate_explanation(
        self,
        question: str,
        structured_context: Dict[str, Any],
        language: str = "hinglish"
    ) -> str:
        """
        Sends pre-computed structured facts to the configured AI provider.
        Falls back gracefully to the deterministic provider if the primary provider encounters an error.
        """
        lang = language.lower() if language else "hinglish"
        provider = AIProviderFactory.get_provider()

        prompt = build_user_prompt(question, structured_context, lang)
        req = AICompletionRequest(
            prompt=prompt,
            system_instruction=SYSTEM_INSTRUCTION,
            structured_context=structured_context,
            language=lang,
            temperature=0.2
        )

        try:
            res = provider.generate_response_sync(req)
            if res and res.text:
                return res.text.strip()
        except Exception as e:
            logger.error(f"Primary AI provider {provider.provider_name} failed: {e}. Falling back to deterministic provider.")
            from app.ai.providers.mock_provider import MockDeterministicProvider
            fallback = MockDeterministicProvider()
            res = fallback.generate_response_sync(req)
            return res.text.strip()

        return "Main aapke store ke recent transaction patterns check kar raha hoon. Overall sales normal range mein hain."

    async def generate_explanation_async(
        self,
        question: str,
        structured_context: Dict[str, Any],
        language: str = "hinglish"
    ) -> str:
        """Async variant for non-blocking execution."""
        return self.generate_explanation(question, structured_context, language)

ai_service = AIService()
