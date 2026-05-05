from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.api.v1.router import api_router
from app.db.database import init_db, close_db


@asynccontextmanager
async def lifespan(app: FastAPI):
    print("🚀 Starting CyberSentinel API...")
    await init_db()
    yield
    print("🛑 Shutting down...")
    await close_db()


app = FastAPI(
    title=settings.API_TITLE,
    version=settings.API_VERSION,
    description="Real-time Cyberattack Detection & Threat Monitoring for Banking Networks",
    docs_url="/api/docs",
    openapi_url="/api/openapi.json",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix="/api/v1")


@app.get("/", tags=["Info"])
def root():
    return {
        "project": "CyberSentinel",
        "version": settings.API_VERSION,
        "docs": "/api/docs",
        "status": "operational",
    }


@app.get("/health", tags=["Info"])
def health():
    return {"status": "healthy"}