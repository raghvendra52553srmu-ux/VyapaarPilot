from fastapi import APIRouter, HTTPException, status
from app.schemas.dto import CreateExperimentRequest, ExperimentResponse
from app.analytics.engine import analytics_engine
from datetime import datetime

router = APIRouter(prefix="/experiments", tags=["Experiments"])

@router.post("", response_model=ExperimentResponse, status_code=status.HTTP_201_CREATED)
def create_experiment(request: CreateExperimentRequest):
    """
    Launch a synthetic promotion experiment and return outcome.
    """
    baseline = 13800.0
    experiment_result = 17250.0
    uplift = analytics_engine.calculate_experiment_uplift(baseline, experiment_result)
    
    return {
        "experiment_id": "EXP001",
        "opportunity_id": request.opportunity_id,
        "merchant_id": request.merchant_id,
        "baseline": baseline,
        "result": experiment_result,
        "uplift_percent": uplift,
        "status": "completed",
        "is_synthetic_demo": True,
        "started_at": datetime.utcnow().isoformat(),
        "completed_at": datetime.utcnow().isoformat(),
        "message": "Synthetic demo experiment completed (+25% uplift)."
    }

@router.get("/{experiment_id}", response_model=ExperimentResponse)
def get_experiment(experiment_id: str):
    """
    Retrieve completed experiment details.
    """
    if experiment_id != "EXP001":
        raise HTTPException(status_code=404, detail="Experiment not found")
        
    return {
        "experiment_id": "EXP001",
        "opportunity_id": "OP001",
        "merchant_id": "M001",
        "baseline": 13800.0,
        "result": 17250.0,
        "uplift_percent": 25.0,
        "status": "completed",
        "is_synthetic_demo": True,
        "started_at": "2026-09-26T10:05:00Z",
        "completed_at": "2026-09-26T10:05:05Z",
        "message": "Synthetic demo experiment completed (+25% uplift)."
    }
