"""
Experiment Service for VyapaarPilot.
Handles experiment creation, baseline vs experiment comparison, and uplift calculations.
"""

import uuid
from datetime import datetime, timedelta
from typing import Dict, Any
from sqlalchemy.orm import Session
from fastapi import HTTPException

from app.models.merchant import Merchant
from app.models.opportunity import Opportunity
from app.models.experiment import Experiment
from app.utils.calculations import calculate_uplift

class ExperimentService:

    def create_experiment(
        self,
        db: Session,
        merchant_id: str,
        opportunity_id: str,
        baseline_amount: float = None,
        experiment_amount: float = None,
        promotion_type: str = "3-hour targeted discount"
    ) -> Dict[str, Any]:
        """
        Creates an experiment linked to an opportunity.
        Validates foreign keys and computes uplift safely.
        """
        merchant = db.query(Merchant).filter(Merchant.merchant_id == merchant_id).first()
        if not merchant:
            raise HTTPException(status_code=404, detail=f"Merchant '{merchant_id}' not found.")

        opp = db.query(Opportunity).filter(Opportunity.opportunity_id == opportunity_id).first()
        if not opp:
            raise HTTPException(status_code=404, detail=f"Opportunity '{opportunity_id}' not found.")

        # If baseline not provided, adopt from opportunity
        baseline = baseline_amount if baseline_amount is not None else float(opp.baseline_amount)
        # If experiment amount not provided, simulate realistic uplift (+20% to +25%)
        exp_amount = experiment_amount if experiment_amount is not None else round(baseline * 1.25, 2)

        uplift = calculate_uplift(baseline, exp_amount)

        exp_id = f"EXP_{uuid.uuid4().hex[:6].upper()}"
        start_time = datetime.utcnow()
        completed_time = start_time + timedelta(hours=3)

        exp = Experiment(
            experiment_id=exp_id,
            merchant_id=merchant_id,
            opportunity_id=opportunity_id,
            baseline_amount=baseline,
            experiment_amount=exp_amount,
            uplift_percent=uplift,
            status="completed",
            started_at=start_time,
            completed_at=completed_time
        )
        db.add(exp)
        db.commit()
        db.refresh(exp)

        return {
            "experiment_id": exp.experiment_id,
            "opportunity_id": exp.opportunity_id,
            "merchant_id": exp.merchant_id,
            "baseline_amount": exp.baseline_amount,
            "baseline": exp.baseline_amount,
            "experiment_amount": exp.experiment_amount,
            "result": exp.experiment_amount,
            "uplift_percent": exp.uplift_percent,
            "status": exp.status,
            "started_at": exp.started_at.isoformat(),
            "completed_at": exp.completed_at.isoformat(),
            "is_synthetic_demo": True,
            "message": f"Experiment created successfully with {uplift:+.1f}% uplift."
        }

    def get_experiment(self, db: Session, experiment_id: str) -> Dict[str, Any]:
        """
        Retrieves experiment details and computes uplift safely.
        """
        exp = db.query(Experiment).filter(Experiment.experiment_id == experiment_id).first()
        if not exp:
            raise HTTPException(status_code=404, detail=f"Experiment '{experiment_id}' not found.")

        uplift = calculate_uplift(float(exp.baseline_amount), float(exp.experiment_amount))

        return {
            "experiment_id": exp.experiment_id,
            "opportunity_id": exp.opportunity_id,
            "merchant_id": exp.merchant_id,
            "baseline_amount": exp.baseline_amount,
            "baseline": exp.baseline_amount,
            "experiment_amount": exp.experiment_amount,
            "result": exp.experiment_amount,
            "uplift_percent": uplift,
            "status": exp.status,
            "started_at": exp.started_at.isoformat() if exp.started_at else None,
            "completed_at": exp.completed_at.isoformat() if exp.completed_at else None,
            "is_synthetic_demo": True,
            "message": f"Experiment {exp.experiment_id} retrieved ({uplift:+.1f}% uplift)."
        }

experiment_service = ExperimentService()
