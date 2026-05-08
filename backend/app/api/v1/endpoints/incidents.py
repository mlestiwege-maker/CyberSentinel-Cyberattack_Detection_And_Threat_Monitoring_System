from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.db.database import get_db
from app.schemas.incident import IncidentOut, IncidentUpdate, IncidentCreate
from app.models.incident import Incident, IncidentStatus
from app.models.user import User
from app.utils.dependencies import get_current_user

router = APIRouter(prefix="/incidents", tags=["Incidents"])


@router.get("/", response_model=List[IncidentOut])
def list_incidents(
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return db.query(Incident).order_by(Incident.created_at.desc()).offset(skip).limit(limit).all()


@router.post("/", response_model=IncidentOut, status_code=201)
def create_incident(
    payload: IncidentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    count = db.query(Incident).count()
    incident = Incident(
        incident_id=f"INC-{__import__('datetime').datetime.now().year}-{str(count + 1).zfill(3)}",
        title=payload.title,
        description=payload.description,
    )
    db.add(incident)
    db.commit()
    db.refresh(incident)
    return incident


@router.get("/{incident_id}", response_model=IncidentOut)
def get_incident(
    incident_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    incident = db.query(Incident).filter(Incident.id == incident_id).first()
    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")
    return incident


@router.patch("/{incident_id}", response_model=IncidentOut)
def update_incident(
    incident_id: int,
    payload: IncidentUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    incident = db.query(Incident).filter(Incident.id == incident_id).first()
    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")
    if payload.status:
        incident.status = payload.status
    if payload.assignee:
        incident.assignee = payload.assignee
    incident.updated_at = __import__('datetime').datetime.now(__import__('datetime').timezone.utc)
    db.commit()
    db.refresh(incident)
    return incident


@router.get("/stats/summary")
def incident_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    total = db.query(Incident).count()
    open_count = db.query(Incident).filter(Incident.status == IncidentStatus.OPEN).count()
    in_progress = db.query(Incident).filter(Incident.status == IncidentStatus.IN_PROGRESS).count()
    resolved = db.query(Incident).filter(Incident.status == IncidentStatus.RESOLVED).count()
    return {"total": total, "open": open_count, "inProgress": in_progress, "resolved": resolved}