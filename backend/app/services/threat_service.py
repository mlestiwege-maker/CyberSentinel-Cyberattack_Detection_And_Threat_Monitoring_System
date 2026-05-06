from datetime import datetime, timezone
from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.models.threat import Threat
from app.models.alert import Alert


def save_threat(db: Session, result: dict, features: dict) -> Threat:
    threat = Threat(
        source_ip      = features.get("source_ip", "unknown"),
        destination_ip = features.get("destination_ip"),
        protocol       = features.get("protocol_type", "tcp"),
        threat_type    = result["threat_type"],
        severity       = result["severity"],
        confidence     = result["confidence"],
        features       = features,
        description    = f"Detected {result['threat_type']} with {result['confidence']:.0%} confidence",
    )
    db.add(threat)
    db.flush()

    alert = Alert(
        threat_id = threat.id,
        message   = f"⚠️ {result['threat_type'].value.upper()} detected from {threat.source_ip} — severity: {result['severity'].value}",
        channel   = "dashboard",
    )
    db.add(alert)
    db.commit()
    db.refresh(threat)
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