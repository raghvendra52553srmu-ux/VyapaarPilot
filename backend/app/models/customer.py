from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base

class Customer(Base):
    __tablename__ = "customers"

    customer_id = Column(String(36), primary_key=True, index=True)
    merchant_id = Column(String(36), ForeignKey("merchants.merchant_id", ondelete="CASCADE"), nullable=False, index=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    merchant = relationship("Merchant", back_populates="customers")
    transactions = relationship("Transaction", back_populates="customer", cascade="all, delete-orphan")
