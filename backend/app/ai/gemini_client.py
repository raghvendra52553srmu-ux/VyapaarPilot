"""
Gemini AI Orchestrator Module
Translates pre-computed numerical context into simple merchant-friendly explanation & action.

CRITICAL SECURITY RULES:
- The LLM has NO direct access to PostgreSQL / database.
- The LLM NEVER independently computes financial metrics or guarantees revenue.
- The LLM receives pre-calculated structured context from Python.
"""

from typing import Dict, Any
from app.core.config import settings

class GeminiAIService:
    """
    AI orchestrator service for generating structured merchant recommendations.
    """

    def __init__(self):
        self.api_key = settings.GEMINI_API_KEY

    def generate_recommendation(self, structured_context: Dict[str, Any], language: str = "hinglish") -> Dict[str, Any]:
        """
        Generates explanation and recommendation from structured numeric context.
        """
        # Scaffold response for initialization phase
        opportunity_id = structured_context.get("opportunity_id", "OP001")
        
        if language.lower() == "hindi":
            explanation = "पिछले 4 हफ्तों से हर मंगलवार को 4 PM से 7 PM के दौरान आपकी बिक्री 24% घट जाती है।"
            recommendation = "मंगलवार 4-7 PM के लिए 10% डिस्काउंट ऑफर चलाएं ताकि बिक्री बढ़े।"
        elif language.lower() == "english":
            explanation = "Sales drop by 24% every Tuesday between 4 PM and 7 PM compared to your historical baseline."
            recommendation = "Run a targeted 3-hour discount promotion on Tuesday evenings to boost customer footfall."
        else:  # Hinglish default
            explanation = "Pichle 4 hafte se Har Tuesday ko 4 PM se 7 PM ke dauran sales 24% tak drop ho rahi hai."
            recommendation = "Tuesday 4-7 PM ke liye 10% discount promo run karein taaki footfall aur sales badhe."

        return {
            "opportunity_id": opportunity_id,
            "title": "Tuesday evening slowdown",
            "explanation": explanation,
            "recommendation": recommendation,
            "experiment_period": "16:00-19:00",
            "estimated_uplift_range": "+15% to +30%"
        }

    def answer_merchant_question(self, merchant_id: str, question: str) -> Dict[str, Any]:
        """
        Interactive Q&A response scaffold.
        """
        return {
            "answer": f"Aapke query '{question}' ke aadhar par: Aapka Tuesday 4 PM se 7 PM ke beech sales ₹13,800 baseline se girkar ₹10,488 par aa raha hai.",
            "suggested_actions": ["Run 3-hour promo on Tuesday 4 PM", "View Opportunity Details"]
        }

gemini_service = GeminiAIService()
