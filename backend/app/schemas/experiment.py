from pydantic import BaseModel, Field
from typing import Optional

class CreateExperimentRequest(BaseModel):
    merchant_id: str
    opportunity_id: str
    baseline_amount: Optional[float] = Field(None, ge=0)
    experiment_amount: Optional[float] = Field(None, ge=0)
    promotion_type: Optional[str] = "3-hour targeted discount"

class ExperimentResponse(BaseModel):
    experiment_id: str
    merchant_id: str
    opportunity_id: str
    baseline_amount: float = Field(..., ge=0)
    baseline: Optional[float] = None
    experiment_amount: float = Field(..., ge=0)
    result: Optional[float] = None
    uplift_percent: float
    status: str = "completed"
    started_at: Optional[str] = None
    completed_at: Optional[str] = None
    message: Optional[str] = None
    is_synthetic_demo: bool = True
