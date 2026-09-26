from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

# Merchant Summary DTO
class MerchantSummaryResponse(BaseModel):
    merchant_id: str
    merchant_name: str
    today_sales: float
    sales_change_percent: float
    transaction_count: int
    average_transaction: float
    currency: str = "INR"

# Daily Trend Item DTO
class DailyTrendItem(BaseModel):
    date: str
    sales: float
    transactions: int

# Hourly Baseline Item DTO
class HourlyBaselineItem(BaseModel):
    hour: str
    baseline_sales: float
    recent_sales: float

# Trends Response DTO
class MerchantTrendsResponse(BaseModel):
    merchant_id: str
    period: str
    daily_trends: List[DailyTrendItem]
    tuesday_hourly_baseline: List[HourlyBaselineItem]

# Opportunity DTO
class OpportunityResponse(BaseModel):
    opportunity_id: str
    merchant_id: str
    type: str
    title: str
    day: str
    period: str
    decline_percent: float
    baseline: float
    current: float
    weeks_observed: int
    confidence: Optional[float] = 0.85

# Recommend Request & Response DTOs
class RecommendRequest(BaseModel):
    merchant_id: str
    preferred_language: str = "hinglish"

class RecommendResponse(BaseModel):
    opportunity_id: str
    title: str
    explanation: str
    recommendation: str
    experiment_period: str
    estimated_uplift_range: str = "+15% to +30%"

# Experiment Request & Response DTOs
class CreateExperimentRequest(BaseModel):
    opportunity_id: str
    merchant_id: str
    promotion_type: Optional[str] = "3-hour targeted discount"

class ExperimentResponse(BaseModel):
    experiment_id: str
    opportunity_id: str
    merchant_id: str
    baseline: float
    result: float
    uplift_percent: float
    status: str
    is_synthetic_demo: bool = True
    started_at: Optional[str] = None
    completed_at: Optional[str] = None
    message: Optional[str] = None

# AI Ask Request & Response DTOs
class AIAskRequest(BaseModel):
    merchant_id: str
    question: str

class AIAskResponse(BaseModel):
    answer: str
    suggested_actions: List[str]
