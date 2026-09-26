import logging
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, declarative_base
from app.core.config import settings

logger = logging.getLogger("vyapaarpilot.database")

db_url = settings.get_database_url()

# Configure engine with proper pooling and dialect specific flags
connect_args = {}
if db_url.startswith("sqlite"):
    connect_args = {"check_same_thread": False}
    engine = create_engine(db_url, connect_args=connect_args)
else:
    # MySQL / PyMySQL connection
    engine = create_engine(
        db_url,
        pool_pre_ping=True,
        pool_recycle=3600,
        pool_size=10,
        max_overflow=20,
        connect_args={"connect_timeout": 5}
    )

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    """Dependency for obtaining a database session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def check_db_connection() -> tuple[bool, str]:
    """
    Checks if the database is reachable.
    Returns (is_connected: bool, message: str) without exposing sensitive credentials.
    """
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return True, "connected"
    except Exception as e:
        err_msg = str(e)
        # Scrub any password from error message
        if settings.DB_PASSWORD and settings.DB_PASSWORD in err_msg:
            err_msg = err_msg.replace(settings.DB_PASSWORD, "******")
        logger.error(f"Database connection check failed: {err_msg}")
        return False, f"Database connection error: {type(e).__name__}"
