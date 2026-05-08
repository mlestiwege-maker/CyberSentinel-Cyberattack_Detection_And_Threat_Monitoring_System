from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.db.database import get_db
from app.models.user import User
from app.utils.dependencies import get_current_user

router = APIRouter(prefix="/voice", tags=["Voice Assistant"])


class VoiceCommand(BaseModel):
    command: str


class VoiceResponse(BaseModel):
    success: bool
    response: str
    action: str


@router.post("/command", response_model=VoiceResponse)
def process_command(
    payload: VoiceCommand,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    cmd = payload.command.lower()
    
    if "incident" in cmd and "open" in cmd:
        return VoiceResponse(success=True, response="Opening incidents board", action="open_incidents")
    elif "threat" in cmd and "refresh" in cmd:
        return VoiceResponse(success=True, response="Refreshing threat monitor", action="refresh_threats")
    elif "alert" in cmd:
        return VoiceResponse(success=True, response="Showing alerts", action="show_alerts")
    elif "dashboard" in cmd:
        return VoiceResponse(success=True, response="Navigating to dashboard", action="open_dashboard")
    else:
        return VoiceResponse(success=True, response=f"Command understood: {payload.command}", action="unknown")


@router.get("/history")
def get_history(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return [
        {"command": "Open Incidents Board", "response": "Opening incidents board", "timestamp": "2024-01-15T10:30:00Z"},
        {"command": "Refresh Threat Monitor", "response": "Refreshing threat monitor", "timestamp": "2024-01-15T10:25:00Z"},
    ]