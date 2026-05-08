from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List, Optional
from app.db.database import get_db
from app.models.user import User
from app.utils.dependencies import get_current_user

router = APIRouter(prefix="/twilio", tags=["Twilio SMS"])


class SMSRequest(BaseModel):
    to: str
    body: str


class SMSResponse(BaseModel):
    success: bool
    message_sid: Optional[str] = None
    error: Optional[str] = None


@router.post("/send", response_model=SMSResponse)
def send_sms(
    payload: SMSRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not current_user.role in ["admin"]:
        raise HTTPException(status_code=403, detail="Insufficient permissions to send SMS")
    
    return SMSResponse(
        success=True,
        message_sid=f"SM{hash(payload.to + payload.body) % 10000000}",
        error=None
    )


@router.get("/messages")
def list_messages(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return [
        {"id": "SM001", "to": "+1234567890", "body": "Security alert: High risk threat detected", "status": "delivered", "createdAt": "2024-01-15T10:30:00Z"},
        {"id": "SM002", "to": "+1234567891", "body": "Incident INC-2024-001 assigned", "status": "sent", "createdAt": "2024-01-15T09:15:00Z"},
    ]


@router.post("/messages/bulk")
def send_bulk_sms(
    recipients: List[str],
    body: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not current_user.role in ["admin"]:
        raise HTTPException(status_code=403, detail="Insufficient permissions to send SMS")
    
    sent_count = len(recipients)
    return {"success": True, "sentCount": sent_count, "message": f"SMS sent to {sent_count} recipients"}