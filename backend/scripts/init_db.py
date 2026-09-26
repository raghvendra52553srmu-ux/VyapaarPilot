"""
VyapaarPilot Database Seeder and Initializer.
Compatible with PostgreSQL (Render), MySQL, and SQLite.
Creates all tables and seeds merchant M001 ("Sharma General Store") with realistic baseline data.
"""

import sys
import uuid
import random
from datetime import datetime, timedelta, timezone
from pathlib import Path

# Add backend directory to sys.path
backend_dir = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(backend_dir))

from app.core.database import engine, SessionLocal, Base
from app.models import Merchant, Customer, Transaction, Opportunity, Experiment

def init_and_seed_database():
    print("=" * 60)
    print(" VyapaarPilot Cloud Database Initializer")
    print("=" * 60)
    print(f"Connecting to database via SQLAlchemy...")
    
    # 1. Create tables
    Base.metadata.create_all(bind=engine)
    print("[1/3] Database tables created successfully.")

    db = SessionLocal()
    try:
        # 2. Check if merchant M001 already exists
        existing_merchant = db.query(Merchant).filter(Merchant.merchant_id == "M001").first()
        if existing_merchant:
            tx_count = db.query(Transaction).filter(Transaction.merchant_id == "M001").count()
            print(f"[2/3] Merchant M001 already exists with {tx_count} transactions.")
            print("[3/3] Database is ready for traffic.")
            return

        print("[2/3] Seeding primary merchant M001 ('Sharma General Store')...")
        m001 = Merchant(
            merchant_id="M001",
            name="Sharma General Store",
            business_type="Retail Grocery",
            city="Lucknow"
        )
        db.add(m001)
        db.commit()

        # Seed customers
        customers = []
        for i in range(1, 101):
            cust_id = f"CUST_{i:05d}"
            c = Customer(customer_id=cust_id, merchant_id="M001")
            customers.append(c)
        db.bulk_save_objects(customers)
        db.commit()

        # Seed realistic transactions (past 90 days)
        print("Generating synthetic transaction history (including Tuesday slowdown pattern)...")
        now = datetime.now(timezone.utc)
        payment_modes = ["UPI", "CARD", "CASH", "WALLET"]
        mode_weights = [0.65, 0.15, 0.15, 0.05]
        
        transactions = []
        cust_ids = [c.customer_id for c in customers]

        for day_offset in range(90, 0, -1):
            day_date = now - timedelta(days=day_offset)
            is_tuesday = (day_date.weekday() == 1)
            
            # Number of transactions in the day
            base_count = random.randint(70, 110)
            for _ in range(base_count):
                hour = random.choices(
                    population=list(range(8, 23)),
                    weights=[2, 4, 6, 8, 10, 8, 7, 6, 12, 14, 15, 12, 8, 4, 2],
                    k=1
                )[0]

                # Tuesday 16:00-19:00 drop
                if is_tuesday and 16 <= hour <= 18:
                    if random.random() < 0.40:  # 40% reduction
                        continue

                minute = random.randint(0, 59)
                tx_time = day_date.replace(hour=hour, minute=minute, second=random.randint(0, 59))
                
                # Typical ticket size
                amount = round(random.lognormvariate(5.0, 0.8), 2)
                amount = max(15.0, min(amount, 8500.0))
                
                pm = random.choices(payment_modes, weights=mode_weights, k=1)[0]
                status = "SUCCESS" if random.random() > 0.02 else "FAILED"
                
                tx = Transaction(
                    transaction_id=f"TX_{uuid.uuid4().hex[:12].upper()}",
                    merchant_id="M001",
                    customer_id=random.choice(cust_ids),
                    timestamp=tx_time,
                    amount=amount,
                    payment_mode=pm,
                    status=status
                )
                transactions.append(tx)

                if len(transactions) >= 1000:
                    db.bulk_save_objects(transactions)
                    db.commit()
                    transactions = []

        if transactions:
            db.bulk_save_objects(transactions)
            db.commit()

        # Seed initial Opportunity
        op = Opportunity(
            opportunity_id="OP001",
            merchant_id="M001",
            type="SLOWDOWN",
            title="Tuesday Evening Slump (4 PM - 7 PM)",
            day_of_week="Tuesday",
            period_start="16:00",
            period_end="19:00",
            baseline_amount=14200.00,
            current_amount=10850.00,
            change_percent=-23.59,
            weeks_observed=4,
            confidence=0.91
        )
        db.add(op)
        db.commit()

        total_tx = db.query(Transaction).filter(Transaction.merchant_id == "M001").count()
        print(f"[3/3] Successfully seeded {total_tx} transactions and baseline opportunity OP001.")
        print("=" * 60)
        print(" Database setup completed successfully!")
        print("=" * 60)

    except Exception as e:
        db.rollback()
        print(f"Error seeding database: {e}")
        raise
    finally:
        db.close()

if __name__ == "__main__":
    init_and_seed_database()
