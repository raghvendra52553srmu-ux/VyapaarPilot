import logging
import time
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, Response, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.core.database import engine, Base, SessionLocal, check_db_connection
from app.routes import merchants, opportunities, experiments, ai, analytics
from app.services.data_seeder import seed_database_if_empty

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
)
logger = logging.getLogger("vyapaarpilot")

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Check database and initialize tables
    logger.info("Starting VyapaarPilot Backend API...")
    is_connected, msg = check_db_connection()
    if is_connected:
        logger.info(f"Database status: {msg}")
        try:
            Base.metadata.create_all(bind=engine)
            db = SessionLocal()
            try:
                seed_database_if_empty(db)
            finally:
                db.close()
        except Exception as e:
            logger.error(f"Error initializing database tables/seed: {e}")
    else:
        logger.warning(f"Database connection issue on startup: {msg}. Retrying on requests.")
    yield
    logger.info("VyapaarPilot Backend API shutdown.")

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="VyapaarPilot API Backend - AI-powered business growth assistant for small merchants.",
    lifespan=lifespan
)

# CORS middleware
cors_origins = [o for o in settings.CORS_ORIGINS if o != "*"] if isinstance(settings.CORS_ORIGINS, list) else []
app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins if cors_origins else ["*"],
    allow_origin_regex=r"https://.*\.(pages\.dev|workers\.dev)",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request logging middleware
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    response: Response = await call_next(request)
    duration = time.time() - start_time
    # Never log sensitive query params or passwords
    clean_url = str(request.url).split("?")[0]
    logger.info(f"{request.method} {clean_url} -> {response.status_code} ({duration:.3f}s)")
    return response

# Include Routers with /api prefix
app.include_router(merchants.router, prefix=settings.API_V1_STR)
app.include_router(opportunities.router, prefix=settings.API_V1_STR)
app.include_router(experiments.router, prefix=settings.API_V1_STR)
app.include_router(ai.router, prefix=settings.API_V1_STR)
app.include_router(analytics.router, prefix=settings.API_V1_STR)

@app.get("/api/health", tags=["Health"])
def health_check():
    """
    Health check endpoint returning system & database connectivity status.
    Never exposes database passwords or internal sensitive details.
    """
    is_connected, message = check_db_connection()
    if is_connected:
        return {
            "status": "ok",
            "database": "connected"
        }
    else:
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={
                "status": "error",
                "database": "disconnected",
                "detail": message
            }
        )

@app.get("/", tags=["Root"])
def root():
    return {
        "project": "VyapaarPilot Backend API",
        "status": "online",
        "version": settings.VERSION,
        "docs_url": "/docs"
    }
