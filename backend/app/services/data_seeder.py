"""
Synthetic Data Seeder for VyapaarPilot.
Generates realistic merchant transaction history (10,000-15,000 transactions over 180 days)
incorporating:
1. Tuesday 16:00-19:00: recurring 20-25% sales slowdown
2. Friday/Saturday: 15-30% higher activity
3. Failed transactions: ~2-4%
4. Natural daily variation
5. Repeat customers & inactive customers
6. Diverse transaction amounts (₹20 to ₹2,500)
7. Diverse payment modes (UPI, QR, CARD, OTHER)
"""

import random
import logging
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.merchant import Merchant
from app.models.customer import Customer
from app.models.transaction import Transaction
from app.models.opportunity import Opportunity
from app.models.experiment import Experiment

logger = logging.getLogger("vyapaarpilot.seeder")

def seed_database_if_empty(db: Session, force: bool = False):
    """
    Checks if merchant M001 and transactions exist. If empty or forced, seeds the dataset.
    """
    existing_merchant = db.query(Merchant).filter(Merchant.merchant_id == "M001").first()
    transaction_count = db.query(func.count(Transaction.transaction_id)).filter(Transaction.merchant_id == "M001").scalar() or 0

    if existing_merchant and transaction_count >= 1000 and not force:
        logger.info(f"Database already contains {transaction_count} transactions for M001. Skipping seeding.")
        return

    logger.info("Seeding synthetic data for VyapaarPilot (Merchant M001)...")

    # 1. Create or get Merchant M001
    if not existing_merchant:
        merchant = Merchant(
            merchant_id="M001",
            name="Sharma General Store",
            business_type="Retail",
            city="Lucknow",
            created_at=datetime.utcnow() - timedelta(days=180)
        )
        db.add(merchant)
        db.commit()
    else:
        merchant = existing_merchant

    # 2. Create customer pool (500 synthetic anonymous customers)
    existing_customers = {c.customer_id: c for c in db.query(Customer).filter(Customer.merchant_id == "M001").all()}
    customer_ids = []
    for i in range(1, 501):
        cid = f"CUST_{i:05d}"
        customer_ids.append(cid)
        if cid not in existing_customers:
            cust = Customer(
                customer_id=cid,
                merchant_id="M001",
                created_at=datetime.utcnow() - timedelta(days=random.randint(60, 180))
            )
            db.add(cust)
    db.commit()

    # 3. Generate Transactions
    # 180 days history up to today
    now = datetime.utcnow()
    start_date = now - timedelta(days=180)

    # Active repeat customer subset (first 150 customers visit regularly)
    frequent_customers = customer_ids[:150]
    # Lapsed/inactive customer subset (customers 151-220 visited heavily in first 90 days, 0 in last 60 days)
    churned_customers = customer_ids[150:220]
    # Occasional customers
    occasional_customers = customer_ids[220:]

    payment_modes = ["UPI", "QR", "CARD", "OTHER"]
    mode_weights = [0.60, 0.25, 0.10, 0.05]

    transactions_to_add = []
    tx_counter = 1

    current_day = start_date
    while current_day <= now:
        day_of_week = current_day.weekday() # 0=Monday, 1=Tuesday, ..., 4=Friday, 5=Saturday, 6=Sunday
        days_from_end = (now - current_day).days

        # Base transaction count for the day
        if day_of_week in (4, 5): # Fri, Sat -> 15-30% higher
            daily_tx_count = random.randint(75, 105)
        elif day_of_week == 6: # Sunday
            daily_tx_count = random.randint(60, 85)
        else: # Mon, Tue, Wed, Thu
            daily_tx_count = random.randint(55, 75)

        for _ in range(daily_tx_count):
            # Pick hour with realistic retail distribution
            hour = random.choices(
                population=list(range(8, 23)),
                weights=[2, 4, 6, 8, 9, 8, 7, 6, 8, 12, 14, 11, 7, 4, 2],
                k=1
            )[0]
            minute = random.randint(0, 59)
            second = random.randint(0, 59)
            tx_time = current_day.replace(hour=hour, minute=minute, second=second)

            # Customer selection
            if days_from_end > 60 and random.random() < 0.25:
                cust_id = random.choice(churned_customers)
            elif random.random() < 0.65:
                cust_id = random.choice(frequent_customers)
            else:
                cust_id = random.choice(occasional_customers)

            # Payment mode
            pay_mode = random.choices(payment_modes, weights=mode_weights, k=1)[0]

            # Amount (General store purchases: ₹20 - ₹1200)
            amount = round(random.triangular(30.0, 1200.0, 220.0), 2)

            # Tuesday 16:00 - 19:00 slowdown:
            # During Tuesday 16:00-19:00, 24% of transactions drop or reduce amount
            if day_of_week == 1 and (16 <= hour <= 18):
                if random.random() < 0.25:
                    continue # Skip this transaction to reflect footfall drop
                amount = round(amount * 0.85, 2)

            # Status: ~3% failed
            status = "FAILED" if random.random() < 0.032 else "SUCCESS"

            tx = Transaction(
                transaction_id=f"TXN_{tx_counter:07d}",
                merchant_id="M001",
                customer_id=cust_id,
                timestamp=tx_time,
                amount=amount,
                payment_mode=pay_mode,
                status=status
            )
            transactions_to_add.append(tx)
            tx_counter += 1

            if len(transactions_to_add) >= 2000:
                db.bulk_save_objects(transactions_to_add)
                db.commit()
                transactions_to_add = []

        current_day += timedelta(days=1)

    if transactions_to_add:
        db.bulk_save_objects(transactions_to_add)
        db.commit()

    # 4. Seed initial baseline Opportunity OP001 if missing
    existing_opp = db.query(Opportunity).filter(Opportunity.opportunity_id == "OP001").first()
    if not existing_opp:
        opp = Opportunity(
            opportunity_id="OP001",
            merchant_id="M001",
            type="slow_period",
            title="Tuesday evening slowdown",
            day_of_week="Tuesday",
            period_start="16:00",
            period_end="19:00",
            baseline_amount=13800.0,
            current_amount=10488.0,
            change_percent=-24.0,
            weeks_observed=4,
            confidence=0.88,
            created_at=datetime.utcnow() - timedelta(days=7)
        )
        db.add(opp)
        db.commit()

    # 5. Seed initial Experiment EXP001 if missing
    existing_exp = db.query(Experiment).filter(Experiment.experiment_id == "EXP001").first()
    if not existing_exp:
        exp = Experiment(
            experiment_id="EXP001",
            merchant_id="M001",
            opportunity_id="OP001",
            baseline_amount=13800.0,
            experiment_amount=17250.0,
            uplift_percent=25.0,
            status="completed",
            started_at=datetime.utcnow() - timedelta(days=5),
            completed_at=datetime.utcnow() - timedelta(days=2)
        )
        db.add(exp)
        db.commit()

    logger.info(f"Seeding completed successfully: {tx_counter - 1} transactions generated.")
