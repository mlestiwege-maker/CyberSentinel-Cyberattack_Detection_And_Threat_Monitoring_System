from datetime import datetime, timezone
from pathlib import Path
import json
import logging
import threading
from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.models.threat import Threat
from app.models.alert import Alert
from app.core.config import settings
from app.services.geoip_service import geolocate_ip
from app.services.email_service import EmailService
from app.services.twilio_gateway import send_sms as send_twilio_sms
try:
    from twilio.rest import Client as TwilioClient
except Exception:
    TwilioClient = None

logger = logging.getLogger(__name__)


def _severity_label(severity: str) -> str:
    return severity.upper() if severity else "UNKNOWN"


def _build_notification_content(*, alert: Alert, threat: Threat, threat_type: str, severity: str, confidence: float) -> tuple[str, str, str]:
    """Create a detailed alert payload for email and a concise SMS body."""
    detected_at = threat.detected_at.isoformat() if threat.detected_at else datetime.now(timezone.utc).isoformat()
    title = f"Security Alert: {threat_type.replace('_', ' ').title()}"
    severity_label = _severity_label(severity)

    message_lines = [
        "CyberSentinel Security Alert",
        f"Title: {title}",
        "",
        f"Severity: {severity_label}",
        "",
        (
            f"Message: Threat detected from {threat.source_ip}. Severity: {severity_label} "
            f"Status: {'Investigating' if severity_label in {'HIGH', 'CRITICAL'} else 'Monitoring'} Confidence: {confidence:.1%}"
        ),
        "",
        f"Time: {detected_at}",
        "",
        "Details:",
        f"Alert_Id: ALT-{threat.id:04d}",
        f"Attack_Type: {threat_type.replace('_', ' ').title()}",
        f"Source_Ip: {threat.source_ip}",
        f"Severity: {severity_label.title()}",
        f"Confidence: {confidence:.1%}",
        f"Description: {threat.description or alert.message}",
    ]
    plain_text = "\n".join(message_lines)
    sms_text = "\n".join(
        [
            f"[CyberSentinel] {severity_label}: {title}",
            f"Threat detected from {threat.source_ip}.",
            f"Severity: {severity_label}",
            f"Status: {'Investigating' if severity_label in {'HIGH', 'CRITICAL'} else 'Monitoring'}",
            f"Confidence: {confidence:.1%}",
            f"Time: {detected_at}",
            f"Alert ID: ALT-{threat.id:04d}",
            f"Attack Type: {threat_type.replace('_', ' ').title()}",
            f"Description: {threat.description or alert.message}",
        ]
    )
    html_body = f"""
        <html>
            <body style="font-family: Arial, sans-serif; line-height: 1.5; color: #111827;">
                <h2 style="color: #b91c1c;">CyberSentinel Security Alert</h2>
                <p><strong>Title:</strong> {title}</p>
                <p><strong>Severity:</strong> {severity_label}</p>
                <p><strong>Message:</strong> Threat detected from {threat.source_ip}. Severity: {severity_label} Status: {'Investigating' if severity_label in {'HIGH', 'CRITICAL'} else 'Monitoring'} Confidence: {confidence:.1%}</p>
                <p><strong>Time:</strong> {detected_at}</p>
                <h3>Details</h3>
                <ul>
                    <li><strong>Alert_Id:</strong> ALT-{threat.id:04d}</li>
                    <li><strong>Attack_Type:</strong> {threat_type.replace('_', ' ').title()}</li>
                    <li><strong>Source_Ip:</strong> {threat.source_ip}</li>
                    <li><strong>Severity:</strong> {severity_label.title()}</li>
                    <li><strong>Confidence:</strong> {confidence:.1%}</li>
                    <li><strong>Description:</strong> {threat.description or alert.message}</li>
                </ul>
                <p>Sent from CyberSentinel automated monitoring.</p>
            </body>
        </html>
        """
    return plain_text, html_body, sms_text


def _append_json_line(file_path: Path, payload: dict) -> None:
    file_path.parent.mkdir(parents=True, exist_ok=True)
    with file_path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(payload, ensure_ascii=False) + "\n")


def _dispatch_notifications(*, alert_message: str, sms_message: str, threat_type: str, severity: str, source_ip: str, description: str, html_body: str) -> None:
    """Send notification traffic in the background so threat persistence stays fast."""
    try:
        email_recipients = list(getattr(settings, "ALERT_EMAIL_RECIPIENTS", []) or [])
        sms_recipients = list(getattr(settings, "ALERT_SMS_RECIPIENTS", []) or [])

        # Email notifications: try SMTP first, otherwise log locally.
        if email_recipients:
            email_ok = False
            if (
                settings.SMTP_USERNAME != "your-email@gmail.com"
                and settings.SMTP_PASSWORD != "your-app-password"
            ):
                try:
                    email_service = EmailService(
                        smtp_server=settings.SMTP_SERVER,
                        smtp_port=settings.SMTP_PORT,
                        sender_email=settings.SMTP_USERNAME,
                        sender_password=settings.SMTP_PASSWORD,
                        use_tls=settings.SMTP_USE_TLS,
                    )
                    # Use the richer notification payload when SMTP is available.
                    # The plain text version is written into the email body.
                    email_ok = email_service.send_email(
                        to_emails=email_recipients,
                        subject=f"CyberSentinel Security Alert: {threat_type.replace('_', ' ').title()} ({_severity_label(severity)})",
                        body=alert_message,
                        html_body=html_body,
                    )
                except Exception as exc:
                    logger.error("Email dispatch failed: %s", exc)

            if not email_ok:
                _append_json_line(
                    Path.home() / ".cybersentinel" / "mock_email.log",
                    {
                        "to": email_recipients,
                        "subject": f"🚨 CyberSentinel Alert: {threat_type} ({severity})",
                        "message": alert_message,
                        "source": source_ip,
                        "severity": severity,
                    },
                )
                logger.info("Email recipients recorded locally for %s", email_recipients)

        # SMS notifications: send via Twilio if available, otherwise log locally.
        if sms_recipients:
            if getattr(settings, "USE_MOCK_TWILIO", False):
                for to_number in sms_recipients:
                    _append_json_line(
                        Path.home() / ".cybersentinel" / "mock_sms.log",
                        {
                            "to": to_number,
                            "from": settings.TWILIO_FROM_NUMBER,
                            "message": sms_message,
                            "user": settings.DEFAULT_ADMIN_EMAIL,
                        },
                    )
                logger.info("Mock SMS recorded for %d recipient(s)", len(sms_recipients))
            else:
                for to_number in sms_recipients:
                    try:
                        if TwilioClient is not None:
                            client = TwilioClient(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
                            sent = client.messages.create(body=sms_message, from_=settings.TWILIO_FROM_NUMBER, to=to_number)
                            logger.info("SMS sent via Twilio to %s (sid=%s)", to_number, sent.sid)
                        else:
                            sent = send_twilio_sms(
                                account_sid=settings.TWILIO_ACCOUNT_SID,
                                auth_token=settings.TWILIO_AUTH_TOKEN,
                                from_number=settings.TWILIO_FROM_NUMBER,
                                to_number=to_number,
                                message=sms_message,
                            )
                            logger.info("SMS sent via Twilio REST API to %s (sid=%s)", to_number, sent.sid)
                    except Exception as exc:
                        logger.error("Twilio send failed for %s: %s", to_number, exc)
                        _append_json_line(
                            Path.home() / ".cybersentinel" / "mock_sms.log",
                            {
                                "to": to_number,
                                "from": settings.TWILIO_FROM_NUMBER,
                                "message": sms_message,
                                "user": settings.DEFAULT_ADMIN_EMAIL,
                                "fallback": "twilio-failed",
                            },
                        )

    except Exception as exc:
        logger.error("Notification dispatch thread failed: %s", exc)


def save_threat(db: Session, result: dict, features: dict) -> Threat:
    geo = geolocate_ip(features.get("source_ip", "unknown")).to_dict()
    enriched_features = dict(features)
    enriched_features["geo"] = geo

    threat = Threat(
        source_ip      = features.get("source_ip", "unknown"),
        destination_ip = features.get("destination_ip"),
        protocol       = features.get("protocol_type", "tcp"),
        threat_type    = result["threat_type"],
        severity       = result["severity"],
        confidence     = result["confidence"],
        features       = enriched_features,
        description    = (
            f"Detected {result['threat_type']} with {result['confidence']:.0%} confidence"
            f" from {geo['location']}"
        ),
    )
    db.add(threat)
    db.flush()

    alert = Alert(
        threat_id = threat.id,
        message   = f"⚠️ {result['threat_type'].value.upper()} detected from {threat.source_ip} ({geo['location']}) — severity: {result['severity'].value}",
        channel   = "dashboard",
    )
    db.add(alert)
    db.commit()
    db.refresh(threat)
    db.refresh(alert)

    alert_message, html_body, sms_text = _build_notification_content(
        alert=alert,
        threat=threat,
        threat_type=result["threat_type"].value,
        severity=result["severity"].value,
        confidence=float(result["confidence"]),
    )
    notification_thread = threading.Thread(
        target=_dispatch_notifications,
        kwargs={
            "alert_message": alert_message,
            "sms_message": sms_text,
            "threat_type": result["threat_type"].value,
            "severity": result["severity"].value,
            "source_ip": threat.source_ip,
            "description": threat.description,
            "html_body": html_body,
        },
        daemon=True,
    )
    notification_thread.start()
    logger.info("Queued notifications for threat %s", threat.id)

    return threat


def get_threats(db: Session, skip: int = 0, limit: int = 50):
    return db.query(Threat).order_by(Threat.detected_at.desc()).offset(skip).limit(limit).all()


def resolve_threat(db: Session, threat_id: int) -> Threat:
    threat = db.query(Threat).filter(Threat.id == threat_id).first()
    if not threat:
        raise HTTPException(status_code=404, detail="Threat not found")
    threat.is_resolved = 1
    threat.resolved_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(threat)
    return threat