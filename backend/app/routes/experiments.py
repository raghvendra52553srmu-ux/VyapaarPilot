from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.experiment import CreateExperimentRequest, ExperimentResponse
from app.services.experiment_service import experiment_service

router = APIRouter(prefix="/experiments", tags=["Experiments"])

@router.post("", response_model=ExperimentResponse, status_code=status.HTTP_201_CREATED)
def create_experiment(request: CreateExperimentRequest, db: Session = Depends(get_db)):
    """
    Create an experiment connected to an opportunity and compute uplift.
    """
    return experiment_service.create_experiment(
        db=db,
        merchant_id=request.merchant_id,
        opportunity_id=request.opportunity_id,
        baseline_amount=request.baseline_amount,
        experiment_amount=request.experiment_amount,
        promotion_type=request.promotion_type
    )

@router.get("/{experiment_id}", response_model=ExperimentResponse)
def get_experiment(experiment_id: str, db: Session = Depends(get_db)):
    """
    Retrieve experiment result, baseline, and uplift percentage.
    """
    return experiment_service.get_experiment(db=db, experiment_id=experiment_id)
