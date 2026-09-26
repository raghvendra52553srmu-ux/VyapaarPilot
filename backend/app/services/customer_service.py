"""
Customer Analytics Service for VyapaarPilot.
Processes anonymous customer transaction records.
Complies with PII safety: Never exposes real names, phone numbers, or addresses.
"""

from datetime import datetime, timedelta
from typing import Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import func
from fastapi import HTTPException

from app.models.merchant import Merchant
from app.models.customer import Customer
from app.models.transaction import Transaction

class CustomerService:

    def get_customer_analytics(self, db: Session, merchant_id: str) -> Dict[str, Any]:
        """
        Computes aggregate customer loyalty and activity metrics:
        - total customers
        - repeat customers (>= 2 transactions)
        - inactive customers (no transactions in last 45 days)
        - average purchase frequency
        - average customer spend
        """
        merchant = db.query(Merchant).filter(Merchant.merchant_id == merchant_id).first()
        if not merchant:
            raise HTTPException(status_code=404, detail=f"Merchant '{merchant_id}' not found.")

        # Total registered customers for this merchant
        total_customers = db.query(func.count(Customer.customer_id)).filter(
            Customer.merchant_id == merchant_id
        ).scalar() or 0

        # Customer transaction frequencies
        customer_tx_stats = db.query(
            Transaction.customer_id,
            func.count(Transaction.transaction_id).label("tx_count"),
            func.sum(Transaction.amount).label("total_spent"),
            func.max(Transaction.timestamp).label("last_active")
        ).filter(
            Transaction.merchant_id == merchant_id,
            Transaction.status == "SUCCESS"
        ).group_by(Transaction.customer_id).all()

        active_customer_count = len(customer_tx_stats)
        effective_total_customers = max(total_customers, active_customer_count)

        if not customer_tx_stats:
            return {
                "merchant_id": merchant_id,
                "total_customers": effective_total_customers,
                "repeat_customers": 0,
                "inactive_customers": 0,
                "repeat_customer_rate": 0.0,
                "average_purchase_frequency": 0.0,
                "average_customer_spend": 0.0,
                "customer_activity_summary": "No customer transactions recorded yet."
            }

        latest_time = max(r.last_active for r in customer_tx_stats)
        cutoff_inactive = latest_time - timedelta(days=45)

        repeat_customers = sum(1 for r in customer_tx_stats if r.tx_count >= 2)
        inactive_customers = sum(1 for r in customer_tx_stats if r.last_active < cutoff_inactive)
        total_sales = sum(float(r.total_spent) for r in customer_tx_stats)
        total_tx = sum(r.tx_count for r in customer_tx_stats)

        repeat_rate = round((repeat_customers / effective_total_customers) * 100.0, 1) if effective_total_customers > 0 else 0.0
        avg_freq = round(total_tx / active_customer_count, 1) if active_customer_count > 0 else 0.0
        avg_spend = round(total_sales / active_customer_count, 2) if active_customer_count > 0 else 0.0

        summary = (
            f"Out of {effective_total_customers} synthetic customers, {repeat_customers} ({repeat_rate}%) "
            f"are repeat shoppers. {inactive_customers} previously active customers have not visited in the past 45 days."
        )

        return {
            "merchant_id": merchant_id,
            "total_customers": effective_total_customers,
            "repeat_customers": repeat_customers,
            "inactive_customers": inactive_customers,
            "repeat_customer_rate": repeat_rate,
            "average_purchase_frequency": avg_freq,
            "average_customer_spend": avg_spend,
            "customer_activity_summary": summary
        }

customer_service = CustomerService()
