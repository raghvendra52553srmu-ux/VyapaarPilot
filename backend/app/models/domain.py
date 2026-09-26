from sqlalchemy import Column, String, Float, Integer, DateTime, ForeignKey, Numeric
from sqlalchemy.orm import relationship
from datetime import datetime
from app.db.session import Base

class Merchant(Base):
    __tablename__ = "merchants"

    merchant_id = Column(String(36), primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    business_type = Column(String(50), nullable=False)
    city = Column(String(50), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    customers = relationship("Customer", back_populates="merchant")
    transactions = relationship("Transaction", back_populates="merchant")
    opportunities = relationship("Opportunity", back_populates="merchant")
    experiments = relationship("Experiment", back_populates="merchant")

class Customer(Base):
    __tablename__ = "customers"

    customer_id = Column(String(36), primary_key=True, index=True)
    merchant_id = Column(String(36), ForeignKey("merchants.merchant_id"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    merchant = relationship("Merchant", back_populates="customers")
    transactions = relationship("Transaction", back_populates="customer")

class Transaction(Base):
    __tablename__ = "transactions"

    transaction_id = Column(String(36), primary_key=True, index=True)
    merchant_id = Column(String(36), ForeignKey("merchants.merchant_id"), index=True, nullable=False)
    customer_id = Column(String(36), ForeignKey("customers.customer_id"), index=True, nullable=False)
    timestamp = Column(DateTime, index=True, nullable=False)
    amount = Column(Float, nullable=False)
    payment_mode = Column(String(20), nullable=False)
    status = Column(String(20), nullable=False)

    merchant = relationship("Merchant", back_populates="transactions")
    customer = relationship("Customer", back_populates="transactions")

class Opportunity(Base):
    __tablename__ = "opportunities"

    opportunity_id = Column(String(36), primary_key=True, index=True)
    merchant_id = Column(String(36), ForeignKey("merchants.merchant_id"), index=True, nullable=False)
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
    experiments = relationship("Experiment", back_populates="opportunity")

class Experiment(Base):
    __tablename__ = "experiments"

    experiment_id = Column(String(36), primary_key=True, index=True)
    merchant_id = Column(String(36), ForeignKey("merchants.merchant_id"), index=True, nullable=False)
    opportunity_id = Column(String(36), ForeignKey("opportunities.opportunity_id"), nullable=False)
    baseline_amount = Column(Float, nullable=False)
    experiment_amount = Column(Float, nullable=False)
    uplift_percent = Column(Float, nullable=False)
    status = Column(String(20), default="completed")
    started_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime, default=datetime.utcnow)

    merchant = relationship("Merchant", back_populates="experiments")
    opportunity = relationship("Opportunity", back_populates="experiments")
