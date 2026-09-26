"""
AI Provider Factory for VyapaarPilot.
Dynamically resolves and provides the active AI provider based on configuration.
"""

import logging
from app.ai.base import AIProvider
from app.ai.providers.groq_provider import GroqProvider
from app.ai.providers.gemini_provider import GeminiProvider
from app.ai.providers.mock_provider import MockDeterministicProvider
from app.core.config import settings

logger = logging.getLogger("vyapaarpilot.ai.factory")

class AIProviderFactory:
    _instance: AIProvider = None

    @classmethod
    def get_provider(cls) -> AIProvider:
        if cls._instance is not None:
            return cls._instance

        provider_type = getattr(settings, "AI_PROVIDER", "groq").lower()

        # 1. Groq Provider
        if (provider_type == "groq" or not settings.GEMINI_API_KEY) and settings.GROQ_API_KEY:
            try:
                cls._instance = GroqProvider(api_key=settings.GROQ_API_KEY, model_name=settings.GROQ_MODEL)
                logger.info(f"Initialized Groq AI provider ({settings.GROQ_MODEL}).")
                return cls._instance
            except Exception as e:
                logger.warning(f"Failed to initialize Groq provider, attempting fallback: {e}")

        # 2. Gemini Provider
        if provider_type == "gemini" and settings.GEMINI_API_KEY:
            try:
                cls._instance = GeminiProvider(api_key=settings.GEMINI_API_KEY)
                logger.info("Initialized Gemini AI provider.")
                return cls._instance
            except Exception as e:
                logger.warning(f"Failed to initialize Gemini provider, falling back to mock: {e}")

        # 3. Fallback to mock deterministic provider
        cls._instance = MockDeterministicProvider()
        logger.info("Initialized MockDeterministic AI provider (fallback).")
        return cls._instance

    @classmethod
    def reset(cls):
        """Reset factory cache for testing."""
        cls._instance = None
