from datetime import datetime
from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Index
from sqlalchemy.orm import relationship
from app.core.database import Base

class Experiment(Base):
    __tablename__ = "experiments"

    experiment_id = Column(String(36), primary_key=True, index=True)
    merchant_id = Column(String(36), ForeignKey("merchants.merchant_id", ondelete="CASCADE"), nullable=False, index=True)
    opportunity_id = Column(String(36), ForeignKey("opportunities.opportunity_id", ondelete="CASCADE"), nullable=False, index=True)
    baseline_amount = Column(Float, nullable=False)
    experiment_amount = Column(Float, nullable=False)
    uplift_percent = Column(Float, nullable=False)
    status = Column(String(20), default="completed")
    started_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime, default=datetime.utcnow)

    merchant = relationship("Merchant", back_populates="experiments")
    opportunity = relationship("Opportunity", back_populates="experiments")

    __table_args__ = (
        Index("idx_experiments_merchant_opp", "merchant_id", "opportunity_id"),
    )
