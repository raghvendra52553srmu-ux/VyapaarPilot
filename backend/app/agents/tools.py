"""
Agent Tools for VyapaarPilot.
Callable internal functions for retrieving deterministic analytics & business facts.
"""

from typing import Dict, Any, List, Optional
from sqlalchemy.orm import Session
from app.services.analytics_service import analytics_service
from app.services.customer_service import customer_service
from app.services.opportunity_service import opportunity_service
from app.services.recommendation_service import recommendation_service
from app.services.experiment_service import experiment_service

class AgentTools:

    @staticmethod
    def get_merchant_summary(merchant_id: str, db: Session) -> Dict[str, Any]:
        """Fetches sales summary (today, week, month, success rate, ATV)."""
        return analytics_service.get_merchant_summary(db=db, merchant_id=merchant_id)

    @staticmethod
    def get_sales_trends(merchant_id: str, db: Session, period: str = "7d") -> Dict[str, Any]:
        """Fetches daily trends and Tuesday hourly baseline."""
        return analytics_service.get_merchant_trends(db=db, merchant_id=merchant_id, period=period)

    @staticmethod
    def get_customer_analytics(merchant_id: str, db: Session) -> Dict[str, Any]:
        """Fetches anonymous customer stats (repeat customers, inactive, frequencies)."""
        return customer_service.get_customer_analytics(db=db, merchant_id=merchant_id)

    @staticmethod
    def get_opportunities(merchant_id: str, db: Session) -> List[Dict[str, Any]]:
        """Detects business opportunities directly from transaction logs."""
        return opportunity_service.detect_opportunities(db=db, merchant_id=merchant_id)

    @staticmethod
    def get_opportunity_details(opportunity_id: str, db: Session) -> Dict[str, Any]:
        """Fetches detailed evidence for a specific opportunity."""
        return opportunity_service.get_opportunity_by_id(db=db, opportunity_id=opportunity_id)

    @staticmethod
    def get_experiment_result(experiment_id: str, db: Session) -> Dict[str, Any]:
        """Fetches baseline vs experiment outcome and uplift."""
        return experiment_service.get_experiment(db=db, experiment_id=experiment_id)

    @staticmethod
    def get_recommendation(opportunity_id: str, db: Session, language: str = "hinglish") -> Dict[str, Any]:
        """Generates structured experiment recommendation for an opportunity."""
        return recommendation_service.generate_recommendation(db=db, opportunity_id=opportunity_id, language=language)

agent_tools = AgentTools()
