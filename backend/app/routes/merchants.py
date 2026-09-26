from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.schemas.merchant import MerchantSummaryResponse
from app.schemas.analytics import MerchantTrendsResponse, CustomerAnalyticsResponse
from app.schemas.opportunity import OpportunityResponse
from app.services.analytics_service import analytics_service
from app.services.customer_service import customer_service
from app.services.opportunity_service import opportunity_service

from app.models.merchant import Merchant

router = APIRouter(prefix="/merchants", tags=["Merchants"])

@router.get("/", response_model=List[dict])
def list_merchants(db: Session = Depends(get_db)):
    """
    List all registered merchants for easy selection in Flutter UI.
    """
    try:
        merchants = db.query(Merchant).all()
        return [
            {
                "merchant_id": m.merchant_id,
                "name": m.name,
                "business_type": m.business_type,
                "city": m.city
            }
            for m in merchants
        ]
    except Exception:
        return []

@router.get("/{merchant_id}/summary", response_model=MerchantSummaryResponse)
def get_merchant_summary(merchant_id: str, db: Session = Depends(get_db)):
    """
    Fetch top-level summary sales metrics for a merchant.
    Only SUCCESS transactions contribute to sales figures.
    """
    return analytics_service.get_merchant_summary(db=db, merchant_id=merchant_id)

@router.get("/{merchant_id}/trends", response_model=MerchantTrendsResponse)
def get_merchant_trends(
    merchant_id: str,
    period: str = Query("7d", description="Trend period (e.g. 7d, 14d)"),
    db: Session = Depends(get_db)
):
    """
    Fetch historical daily, weekly, monthly and Tuesday hourly baseline trends for charting.
    Calculated directly from transactions without static tables.
    """
    return analytics_service.get_merchant_trends(db=db, merchant_id=merchant_id, period=period)

@router.get("/{merchant_id}/customers/analytics", response_model=CustomerAnalyticsResponse)
def get_customer_analytics(merchant_id: str, db: Session = Depends(get_db)):
    """
    Fetch anonymous synthetic customer analytics:
    Total, repeat, and inactive customers, purchase frequency and average spend.
    """
    return customer_service.get_customer_analytics(db=db, merchant_id=merchant_id)

@router.get("/{merchant_id}/opportunities", response_model=List[OpportunityResponse])
def get_merchant_opportunities(merchant_id: str, db: Session = Depends(get_db)):
    """
    Detect and list active business opportunities discovered from transaction history.
    """
    return opportunity_service.detect_opportunities(db=db, merchant_id=merchant_id)
