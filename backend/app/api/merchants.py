from fastapi import APIRouter, HTTPException
from typing import List
from app.schemas.dto import MerchantSummaryResponse, MerchantTrendsResponse, OpportunityResponse
from app.analytics.engine import analytics_engine

router = APIRouter(prefix="/merchants", tags=["Merchants"])

@router.get("/{merchant_id}/summary", response_model=MerchantSummaryResponse)
def get_merchant_summary(merchant_id: str):
    """
    Fetch top-level summary sales metrics for a merchant.
    """
    summary = analytics_engine.calculate_merchant_summary(merchant_id)
    return summary

@router.get("/{merchant_id}/trends", response_model=MerchantTrendsResponse)
def get_merchant_trends(merchant_id: str, period: str = "7d"):
    """
    Fetch historical daily & Tuesday hourly trend baseline for charts.
    """
    return {
        "merchant_id": merchant_id,
        "period": period,
        "daily_trends": [
            {"date": "2026-09-20", "sales": 22100.0, "transactions": 85},
            {"date": "2026-09-21", "sales": 21500.0, "transactions": 82},
            {"date": "2026-09-22", "sales": 13800.0, "transactions": 54},
            {"date": "2026-09-23", "sales": 23400.0, "transactions": 90},
            {"date": "2026-09-24", "sales": 24100.0, "transactions": 92},
            {"date": "2026-09-25", "sales": 26800.0, "transactions": 102},
            {"date": "2026-09-26", "sales": 18420.0, "transactions": 73}
        ],
        "tuesday_hourly_baseline": [
            {"hour": "16:00", "baseline_sales": 4600.0, "recent_sales": 3496.0},
            {"hour": "17:00", "baseline_sales": 4800.0, "recent_sales": 3648.0},
            {"hour": "18:00", "baseline_sales": 4400.0, "recent_sales": 3344.0}
        ]
    }

@router.get("/{merchant_id}/opportunities", response_model=List[OpportunityResponse])
def get_merchant_opportunities(merchant_id: str):
    """
    List underperformance opportunities detected for a merchant.
    """
    opportunities = analytics_engine.detect_underperformance_opportunities(merchant_id)
    return opportunities
