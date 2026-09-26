from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Index
from sqlalchemy.orm import relationship
from app.core.database import Base

class Transaction(Base):
    __tablename__ = "transactions"

    transaction_id = Column(String(36), primary_key=True, index=True)
    merchant_id = Column(String(36), ForeignKey("merchants.merchant_id", ondelete="CASCADE"), nullable=False, index=True)
    customer_id = Column(String(36), ForeignKey("customers.customer_id", ondelete="CASCADE"), nullable=False, index=True)
    timestamp = Column(DateTime, nullable=False, index=True)
    amount = Column(Float, nullable=False)
    payment_mode = Column(String(20), nullable=False)
    status = Column(String(20), nullable=False)

    merchant = relationship("Merchant", back_populates="transactions")
    customer = relationship("Customer", back_populates="transactions")

    __table_args__ = (
        Index("idx_transactions_merchant_time", "merchant_id", "timestamp"),
        Index("idx_transactions_merchant_status", "merchant_id", "status"),
    )
