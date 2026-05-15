from fastapi import APIRouter
from app.api.v1.endpoints import auth, threats, alerts, dashboard, notifications

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(threats.router)
api_router.include_router(alerts.router)
api_router.include_router(dashboard.router)
api_router.include_router(notifications.router)