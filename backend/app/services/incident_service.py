from datetime import datetime, timezone
from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.models.incident import Incident, IncidentStatus


def get_incidents(db: Session, skip: int = 0, limit: int = 50):
    return db.query(Incident).order_by(Incident.created_at.desc()).offset(skip).limit(limit).all()


def get_incident(db: Session, incident_id: int) -> Incident:
    incident = db.query(Incident).filter(Incident.id == incident_id).first()
    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")
    return incident


def create_incident(db: Session, title: str, description: str = None) -> Incident:
    count = db.query(Incident).count()
    incident = Incident(
        incident_id=f"INC-{datetime.now().year}-{str(count + 1).zfill(3)}",
        title=title,
        description=description,
    )
    db.add(incident)
    db.commit()
    db.refresh(incident)
    return incident


def update_incident(db: Session, incident_id: int, status: IncidentStatus = None, assignee: str = None) -> Incident:
    incident = db.query(Incident).filter(Incident.id == incident_id).first()
    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")
    if status:
        incident.status = status
    if assignee:
        incident.assignee = assignee
    incident.updated_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(incident)
    return incident