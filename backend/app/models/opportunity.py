from datetime import datetime
from sqlalchemy import Column, String, Float, Integer, DateTime, ForeignKey, Index
from sqlalchemy.orm import relationship
from app.core.database import Base

class Opportunity(Base):
    __tablename__ = "opportunities"

    opportunity_id = Column(String(36), primary_key=True, index=True)
    merchant_id = Column(String(36), ForeignKey("merchants.merchant_id", ondelete="CASCADE"), nullable=False, index=True)
    type = Column(String(50), nullable=False)
    title = Column(String(150), nullable=False)
    day_of_week = Column(String(15), nullable=False)
    period_start = Column(String(5), nullable=False)
    period_end = Column(String(5), nullable=False)
    baseline_amount = Column(Float, nullable=False)
    current_amount = Column(Float, nullable=False)
    change_percent = Column(Float, nullable=False)
    weeks_observed = Column(Integer, default=4)
    confidence = Column(Float, default=0.85)
    created_at = Column(DateTime, default=datetime.utcnow)

    merchant = relationship("Merchant", back_populates="opportunities")
    experiments = relationship("Experiment", back_populates="opportunity", cascade="all, delete-orphan")

    __table_args__ = (
        Index("idx_opportunities_merchant_created", "merchant_id", "created_at"),
    )
