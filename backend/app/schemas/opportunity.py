from pydantic import BaseModel, Field
from typing import Optional, Dict, Any

class OpportunityResponse(BaseModel):
    opportunity_id: str
    merchant_id: str
    type: str
    title: str
    day_of_week: Optional[str] = None
    day: Optional[str] = None
    period_start: Optional[str] = None
    period_end: Optional[str] = None
    period: Optional[str] = None
    baseline_amount: float = Field(..., ge=0)
    baseline: Optional[float] = None
    current_amount: float = Field(..., ge=0)
    current: Optional[float] = None
    change_percent: float
    decline_percent: Optional[float] = None
    weeks_observed: int = Field(4, ge=1)
    confidence: float = Field(0.85, ge=0.0, le=1.0)
    evidence: Optional[Dict[str, Any]] = None
    recommended_action: Optional[str] = None

class RecommendRequest(BaseModel):
    merchant_id: Optional[str] = None
    preferred_language: Optional[str] = "hinglish"
    language: Optional[str] = None

class RecommendResponse(BaseModel):
    opportunity_id: str
    title: str
    recommendation: str
    reason: str
    supporting_evidence: Dict[str, Any] = {}
    confidence: float
    safety_limitation: str
    explanation: Optional[str] = None
    experiment_period: Optional[str] = None
    estimated_uplift_range: Optional[str] = "+15% to +30%"
