from typing import List
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.opportunity import OpportunityResponse, RecommendRequest, RecommendResponse
from app.services.opportunity_service import opportunity_service
from app.services.recommendation_service import recommendation_service

router = APIRouter(prefix="/opportunities", tags=["Opportunities"])

@router.get("/", response_model=List[OpportunityResponse])
def list_opportunities(merchant_id: str = Query(..., description="Merchant ID"), db: Session = Depends(get_db)):
    """
    Detect and list active opportunities for a merchant.
    """
    return opportunity_service.detect_opportunities(db=db, merchant_id=merchant_id)

@router.get("/detect", response_model=List[OpportunityResponse])
def detect_opportunities_endpoint(merchant_id: str = Query(..., description="Merchant ID"), db: Session = Depends(get_db)):
    """
    Explicitly trigger detection of opportunities for a merchant.
    """
    return opportunity_service.detect_opportunities(db=db, merchant_id=merchant_id)

@router.get("/{opportunity_id}", response_model=OpportunityResponse)
def get_opportunity(opportunity_id: str, db: Session = Depends(get_db)):
    """
    Get detailed evidence and baseline for a single opportunity.
    """
    return opportunity_service.get_opportunity_by_id(db=db, opportunity_id=opportunity_id)

@router.post("/{opportunity_id}/recommend", response_model=RecommendResponse)
def recommend_action(
    opportunity_id: str,
    request: RecommendRequest,
    db: Session = Depends(get_db)
):
    """
    Generate a safe, structured promotional recommendation framed as an experiment.
    Never provides regulated financial advice.
    """
    pref_lang = request.language or request.preferred_language or "hinglish"
    return recommendation_service.generate_recommendation(
        db=db,
        opportunity_id=opportunity_id,
        language=pref_lang
    )
