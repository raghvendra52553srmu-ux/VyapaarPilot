from datetime import datetime
from sqlalchemy import Column, String, DateTime
from sqlalchemy.orm import relationship
from app.core.database import Base

class Merchant(Base):
    __tablename__ = "merchants"

    merchant_id = Column(String(36), primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    business_type = Column(String(50), nullable=False)
    city = Column(String(50), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    customers = relationship("Customer", back_populates="merchant", cascade="all, delete-orphan")
    transactions = relationship("Transaction", back_populates="merchant", cascade="all, delete-orphan")
    opportunities = relationship("Opportunity", back_populates="merchant", cascade="all, delete-orphan")
    experiments = relationship("Experiment", back_populates="merchant", cascade="all, delete-orphan")
