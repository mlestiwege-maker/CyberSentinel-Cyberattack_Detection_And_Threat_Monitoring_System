from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.db.database import get_db
from app.models.user import User
from app.schemas.user import UserOut
from app.utils.dependencies import get_current_user

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/", response_model=List[UserOut])
def list_users(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    users = db.query(User).all()
    return users


@router.get("/roles")
def get_roles(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return [
        {"role": "admin", "permissions": ["alerts.read", "alerts.update", "threats.read", "threats.manage", "incidents.manage", "reports.export", "twilio.send", "voice.command"]},
        {"role": "security_analyst", "permissions": ["alerts.read", "threats.read", "incidents.manage"]},
        {"role": "incident_responder", "permissions": ["incidents.manage"]},
        {"role": "threat_monitor", "permissions": ["threats.read"]},
        {"role": "testing", "permissions": ["threats.read", "alerts.read"]},
        {"role": "documentation", "permissions": ["reports.export"]},
    ]


@router.get("/team")
def get_team(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return [
        {"name": "Admin", "role": "Security Analyst", "assignedRole": "admin", "status": "Online", "assignment": "Incident response and oversight"},
        {"name": "Lestiwege Mufutumari", "role": "Frontend Developer", "assignedRole": "admin", "status": "Online", "assignment": "Flutter UI and API integration"},
        {"name": "Tadiwa Sharara", "role": "Project Planning", "assignedRole": "security_analyst", "status": "Online", "assignment": "Scope, requirements, architecture"},
        {"name": "Bunu Anesu", "role": "Backend Development", "assignedRole": "incident_responder", "status": "Offline", "assignment": "FastAPI APIs and business logic"},
        {"name": "Madamu Creig", "role": "Network Monitoring", "assignedRole": "threat_monitor", "status": "Online", "assignment": "Traffic capture and preprocessing"},
        {"name": "Davison Karamenti", "role": "Machine Learning", "assignedRole": "testing", "status": "Online", "assignment": "Anomaly detection model integration"},
        {"name": "Dzimbanhete Bhunu", "role": "Threat Detection", "assignedRole": "incident_responder", "status": "Online", "assignment": "Port scan and brute force detection"},
        {"name": "Tinashe Matyamaenza", "role": "Testing", "assignedRole": "testing", "status": "Online", "assignment": "Unit, integration, and system testing"},
        {"name": "Agatha Katiyo", "role": "Documentation", "assignedRole": "documentation", "status": "Offline", "assignment": "Reports and presentation preparation"},
    ]