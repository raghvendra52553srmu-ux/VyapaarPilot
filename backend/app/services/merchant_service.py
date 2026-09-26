"""
Merchant Service Layer
Encapsulates business operations between API routes, Database, Analytics engine, and AI orchestrator.
"""

from typing import Dict, Any, List
from app.analytics.engine import analytics_engine
from app.ai.gemini_client import gemini_service

class MerchantService:
    """
    Business service layer orchestrator.
    """

    def get_summary(self, merchant_id: str) -> Dict[str, Any]:
        return analytics_engine.calculate_merchant_summary(merchant_id)

    def get_opportunities(self, merchant_id: str) -> List[Dict[str, Any]]:
        return analytics_engine.detect_underperformance_opportunities(merchant_id)

merchant_service = MerchantService()
