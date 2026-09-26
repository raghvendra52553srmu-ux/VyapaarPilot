from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.services.analytics_service import analytics_service

router = APIRouter(prefix="/analytics", tags=["Analytics"])

@router.get("/summary/{merchant_id}")
def get_analytics_summary_path(merchant_id: str, db: Session = Depends(get_db)):
    return analytics_service.get_merchant_summary(db=db, merchant_id=merchant_id)

@router.get("/summary")
def get_analytics_summary_query(merchant_id: str = Query(..., description="Merchant ID"), db: Session = Depends(get_db)):
    return analytics_service.get_merchant_summary(db=db, merchant_id=merchant_id)

@router.get("/trends/{merchant_id}")
def get_analytics_trends_path(merchant_id: str, period: str = "7d", db: Session = Depends(get_db)):
    return analytics_service.get_merchant_trends(db=db, merchant_id=merchant_id, period=period)

@router.get("/trends")
def get_analytics_trends_query(merchant_id: str = Query(..., description="Merchant ID"), period: str = "7d", db: Session = Depends(get_db)):
    return analytics_service.get_merchant_trends(db=db, merchant_id=merchant_id, period=period)
