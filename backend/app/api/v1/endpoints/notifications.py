"""Notification endpoints for sending alerts via email and SMS."""

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, EmailStr
from typing import List, Optional
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.utils.dependencies import get_current_user, require_admin
from app.models.user import User
from app.core.config import settings
from app.services.email_service import EmailService
from app.services.twilio_gateway import send_sms as send_twilio_sms
import logging
import json
from pathlib import Path
from app.core.config import settings
try:
    from twilio.rest import Client as TwilioClient
except Exception:
    TwilioClient = None

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/notifications", tags=["Notifications"])


class EmailAlertRequest(BaseModel):
    """Request to send alert via email."""
    recipients: List[EmailStr]
    subject: str
    message: str
    threat_type: Optional[str] = None
    threat_severity: Optional[str] = None
    threat_source: Optional[str] = None


class SMSAlertRequest(BaseModel):
    """Request to send alert via SMS (Twilio)."""
    phone_number: str
    message: str


class EmailTestRequest(BaseModel):
    """Request to test email configuration."""
    test_recipient: EmailStr


class SMSTestRequest(BaseModel):
    phone_number: str
    message: str


def _read_last_json_lines(file_path: Path, limit: int = 5) -> List[dict]:
    if not file_path.exists():
        return []

    entries: List[dict] = []
    with file_path.open('r', encoding='utf-8') as handle:
        for line in handle:
            line = line.strip()
            if not line:
                continue
            try:
                entries.append(json.loads(line))
            except Exception:
                continue
    return entries[-limit:]


@router.post("/email/send")
async def send_email_alert(
    request: EmailAlertRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Send alert via email.
    
    Requires: Current user with proper permissions.
    """
    try:
        # Check if SMTP is configured
        if (
            settings.SMTP_USERNAME == "your-email@gmail.com"
            or settings.SMTP_PASSWORD == "your-app-password"
        ):
            raise HTTPException(
                status_code=503,
                detail="Email service not configured. Please set SMTP credentials in .env"
            )
        
        # Initialize email service
        email_service = EmailService(
            smtp_server=settings.SMTP_SERVER,
            smtp_port=settings.SMTP_PORT,
            sender_email=settings.SMTP_USERNAME,
            sender_password=settings.SMTP_PASSWORD,
            use_tls=settings.SMTP_USE_TLS,
        )
        
        # Send threat alert if threat details provided
        if request.threat_type and request.threat_severity:
            success = email_service.send_threat_alert(
                to_emails=request.recipients,
                threat_type=request.threat_type,
                threat_severity=request.threat_severity,
                threat_description=request.message,
                threat_source=request.threat_source or "Unknown",
            )
        else:
            # Send generic email
            success = email_service.send_email(
                to_emails=request.recipients,
                subject=request.subject,
                body=request.message,
            )
        
        if not success:
            raise HTTPException(
                status_code=500,
                detail="Failed to send email. Check SMTP configuration."
            )
        
        logger.info(f"Email alert sent to {request.recipients} by {current_user.email}")
        return {"success": True, "message": f"Email sent to {len(request.recipients)} recipient(s)"}
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error sending email: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/email/test")
async def test_email_configuration(
    request: EmailTestRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Test email configuration by sending a test email.
    
    Requires: Current user.
    """
    try:
        # Check if SMTP is configured
        if (
            settings.SMTP_USERNAME == "your-email@gmail.com"
            or settings.SMTP_PASSWORD == "your-app-password"
        ):
            raise HTTPException(
                status_code=503,
                detail="Email service not configured. Please set SMTP credentials in .env"
            )
        
        # Initialize email service
        email_service = EmailService(
            smtp_server=settings.SMTP_SERVER,
            smtp_port=settings.SMTP_PORT,
            sender_email=settings.SMTP_USERNAME,
            sender_password=settings.SMTP_PASSWORD,
            use_tls=settings.SMTP_USE_TLS,
        )
        
        # Send test email
        success = email_service.send_email(
            to_emails=[request.test_recipient],
            subject="CyberSentinel Email Configuration Test",
            body="This is a test email from CyberSentinel to verify your email configuration is working correctly.",
            html_body="""
            <html>
                <body style="font-family: Arial, sans-serif;">
                    <h2 style="color: #1e40af;">✓ CyberSentinel Email Configuration Test</h2>
                    <p>This is a test email from CyberSentinel to verify your email configuration is working correctly.</p>
                    <p style="color: #666;">If you received this email, your email service is properly configured!</p>
                </body>
            </html>
            """
        )
        
        if not success:
            raise HTTPException(
                status_code=500,
                detail="Failed to send test email. Check SMTP configuration."
            )
        
        logger.info(f"Test email sent to {request.test_recipient} by {current_user.email}")
        return {"success": True, "message": f"Test email sent to {request.test_recipient}"}
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error sending test email: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/email/status")
async def get_email_configuration_status(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Get email service configuration status.
    
    Returns whether email service is properly configured.
    """
    is_configured = (
        settings.SMTP_USERNAME != "your-email@gmail.com"
        and settings.SMTP_PASSWORD != "your-app-password"
    )
    
    return {
        "configured": is_configured,
        "smtp_server": settings.SMTP_SERVER if is_configured else None,
        "smtp_port": settings.SMTP_PORT if is_configured else None,
        "sender_email": settings.SMTP_USERNAME if is_configured else None,
    }


@router.get("/status")
async def get_notification_status(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Return a compact snapshot of notification configuration and recent dispatch activity."""
    sms_mode = "mock" if getattr(settings, 'USE_MOCK_TWILIO', False) else "twilio"
    sms_log_path = Path.home() / '.cybersentinel' / 'mock_sms.log'
    email_log_path = Path.home() / '.cybersentinel' / 'mock_email.log'

    email_configured = (
        settings.SMTP_USERNAME != "your-email@gmail.com"
        and settings.SMTP_PASSWORD != "your-app-password"
    )
    twilio_configured = bool(
        settings.TWILIO_ACCOUNT_SID
        and settings.TWILIO_AUTH_TOKEN
        and settings.TWILIO_FROM_NUMBER
    )
    sms_recipients = getattr(settings, 'ALERT_SMS_RECIPIENTS', []) or []
    email_recipients = getattr(settings, 'ALERT_EMAIL_RECIPIENTS', []) or []

    return {
        "sms": {
            "mode": sms_mode,
            "configured": bool(sms_recipients) and twilio_configured,
            "twilio_configured": twilio_configured,
            "recipients": sms_recipients,
            "recent": _read_last_json_lines(sms_log_path, limit=3),
        },
        "email": {
            "configured": email_configured,
            "recipients": email_recipients,
            "recent": _read_last_json_lines(email_log_path, limit=3),
        },
        "delivery_health": "automatic" if (email_configured or (twilio_configured and sms_recipients)) else "manual",
    }



@router.post('/sms/test')
async def test_sms(
    request: SMSTestRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Test SMS delivery. In mock mode this will record the message locally and return success."""
    try:
        # If mock mode is enabled, write the test SMS to a local log and return success
        if getattr(settings, 'USE_MOCK_TWILIO', False):
            log_dir = Path.home() / '.cybersentinel'
            log_dir.mkdir(parents=True, exist_ok=True)
            out_file = log_dir / 'mock_sms.log'
            entry = {
                'to': request.phone_number,
                'from': settings.TWILIO_FROM_NUMBER,
                'message': request.message,
                'user': current_user.email,
            }
            with out_file.open('a') as f:
                f.write(json.dumps(entry) + '\n')
            logger.info(f"Mock SMS recorded to {out_file}")
            return {"success": True, "message": "Mock SMS recorded", "details": entry}

        # Otherwise, attempt to send via Twilio REST API (works even without SDK)
        if TwilioClient is None:
            sent = send_twilio_sms(
                account_sid=settings.TWILIO_ACCOUNT_SID,
                auth_token=settings.TWILIO_AUTH_TOKEN,
                from_number=settings.TWILIO_FROM_NUMBER,
                to_number=request.phone_number,
                message=request.message,
            )
            logger.info(f"SMS sent via Twilio REST API: {sent.sid} to {request.phone_number}")
            return {"success": True, "sid": sent.sid, "status": sent.status}

        client = TwilioClient(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
        sent = client.messages.create(
            body=request.message,
            from_=settings.TWILIO_FROM_NUMBER,
            to=request.phone_number,
        )
        logger.info(f"SMS sent via Twilio: {sent.sid} to {request.phone_number}")
        return {"success": True, "sid": sent.sid, "status": sent.status}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error sending SMS: {e}")
        raise HTTPException(status_code=500, detail=str(e))
