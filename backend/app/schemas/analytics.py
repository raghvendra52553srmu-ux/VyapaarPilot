from pydantic import BaseModel, Field
from typing import List, Optional

class DailyTrendItem(BaseModel):
    date: str
    sales: float = Field(..., ge=0)
    transactions: int = Field(..., ge=0)

class WeeklyTrendItem(BaseModel):
    week: str
    sales: float = Field(..., ge=0)
    transactions: int = Field(..., ge=0)

class MonthlyTrendItem(BaseModel):
    month: str
    sales: float = Field(..., ge=0)
    transactions: int = Field(..., ge=0)

class HourlyBaselineItem(BaseModel):
    hour: str
    baseline_sales: float = Field(..., ge=0)
    recent_sales: float = Field(..., ge=0)

class MerchantTrendsResponse(BaseModel):
    merchant_id: str
    period: str = "7d"
    daily_trends: List[DailyTrendItem] = []
    weekly_trends: List[WeeklyTrendItem] = []
    monthly_trends: List[MonthlyTrendItem] = []
    tuesday_hourly_baseline: List[HourlyBaselineItem] = []

class CustomerAnalyticsResponse(BaseModel):
    merchant_id: str
    total_customers: int = Field(..., ge=0)
    repeat_customers: int = Field(..., ge=0)
    inactive_customers: int = Field(..., ge=0)
    repeat_customer_rate: float = Field(0.0, ge=0, le=100)
    average_purchase_frequency: float = Field(0.0, ge=0)
    average_customer_spend: float = Field(0.0, ge=0)
    customer_activity_summary: str
