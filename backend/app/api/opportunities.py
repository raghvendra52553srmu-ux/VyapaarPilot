from fastapi import APIRouter, HTTPException
from app.schemas.dto import OpportunityResponse, RecommendRequest, RecommendResponse
from app.ai.gemini_client import gemini_service

router = APIRouter(prefix="/opportunities", tags=["Opportunities"])

@router.get("/{opportunity_id}", response_model=OpportunityResponse)
def get_opportunity(opportunity_id: str):
    """
    Get detailed information for a single opportunity.
    """
    if opportunity_id != "OP001":
        raise HTTPException(status_code=404, detail="Opportunity not found")
        
    return {
        "opportunity_id": "OP001",
        "merchant_id": "M001",
        "type": "slow_period",
        "title": "Tuesday evening slowdown",
        "day": "Tuesday",
        "period": "16:00-19:00",
        "decline_percent": 24.0,
        "baseline": 13800.0,
        "current": 10488.0,
        "weeks_observed": 4,
        "confidence": 0.85
    }

@router.post("/{opportunity_id}/recommend", response_model=RecommendResponse)
def recommend_action(opportunity_id: str, request: RecommendRequest):
    """
    Generate AI explanation and recommendation for an opportunity via Gemini.
    """
    structured_context = {
        "opportunity_id": opportunity_id,
        "merchant_id": request.merchant_id,
        "merchant_type": "retail",
        "opportunity_type": "slow_period",
        "day": "Tuesday",
        "period": "16:00-19:00",
        "decline_percent": 24.0,
        "weeks_observed": 4,
        "baseline_sales": 13800.0,
        "recent_sales": 10488.0
    }
    
    recommendation = gemini_service.generate_recommendation(
        structured_context=structured_context,
        language=request.preferred_language
    )
    return recommendation
