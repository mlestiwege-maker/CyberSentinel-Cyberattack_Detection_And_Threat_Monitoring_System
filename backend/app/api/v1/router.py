from fastapi import APIRouter
from app.api.v1.endpoints import auth, threats, alerts, dashboard, incidents, twilio, users, voice, reports

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(threats.router)
api_router.include_router(alerts.router)
api_router.include_router(dashboard.router)
api_router.include_router(incidents.router)
api_router.include_router(twilio.router)
api_router.include_router(users.router)
api_router.include_router(voice.router)
api_router.include_router(reports.router)