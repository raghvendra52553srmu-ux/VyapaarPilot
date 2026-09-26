import pytest
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from fastapi.testclient import TestClient
from datetime import datetime, timedelta, timezone

from app.core.database import Base, get_db
from app.models.merchant import Merchant
from app.models.customer import Customer
from app.models.transaction import Transaction
from app.models.opportunity import Opportunity
from app.models.experiment import Experiment
from app.main import app

# Use in-memory SQLite with StaticPool so all threads/sessions share the exact same in-memory DB
TEST_SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

test_engine = create_engine(
    TEST_SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)

@pytest.fixture(scope="session", autouse=True)
def init_test_database():
    Base.metadata.create_all(bind=test_engine)
    db = TestingSessionLocal()

    # Seed merchant M001
    m = Merchant(
        merchant_id="M001",
        name="Sharma General Store",
        business_type="Retail",
        city="Lucknow"
    )
    db.add(m)

    # Seed customers
    for i in range(1, 21):
        c = Customer(customer_id=f"CUST_{i:05d}", merchant_id="M001")
        db.add(c)
    db.commit()

    now = datetime.now(timezone.utc).replace(tzinfo=None)

    # Seed transactions with Tuesday slowdown and repeat customers
    for day_offset in range(14):
        tx_day = now - timedelta(days=day_offset)
        for hour in [10, 14, 16, 17, 18, 20]:
            is_tue_slow = (tx_day.weekday() == 1 and hour in [16, 17, 18])
            amount = 150.0 if not is_tue_slow else 75.0
            status = "SUCCESS" if hour != 20 else "FAILED"
            tx = Transaction(
                transaction_id=f"TXN_{day_offset}_{hour}",
                merchant_id="M001",
                customer_id=f"CUST_{(hour % 10) + 1:05d}",
                timestamp=tx_day.replace(hour=hour, minute=0, second=0),
                amount=amount,
                payment_mode="UPI",
                status=status
            )
            db.add(tx)
    db.commit()

    # Seed opportunity OP001
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
        confidence=0.88
    )
    db.add(opp)

    # Seed experiment EXP001
    exp = Experiment(
        experiment_id="EXP001",
        merchant_id="M001",
        opportunity_id="OP001",
        baseline_amount=13800.0,
        experiment_amount=17250.0,
        uplift_percent=25.0,
        status="completed"
    )
    db.add(exp)
    db.commit()

    yield

    Base.metadata.drop_all(bind=test_engine)

@pytest.fixture
def db():
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()

@pytest.fixture
def client():
    def override_get_db():
        session = TestingSessionLocal()
        try:
            yield session
        finally:
            session.close()

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()
