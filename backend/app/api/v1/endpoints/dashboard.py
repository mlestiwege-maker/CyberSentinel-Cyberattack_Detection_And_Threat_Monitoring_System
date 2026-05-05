from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.models.threat import Threat, ThreatSeverity
from app.models.alert import Alert
from app.utils.dependencies import get_current_user
from app.models.user import User

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


@router.get("/summary")
def summary(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return {
        "total_threats":  db.query(Threat).count(),
        "open_threats":   db.query(Threat).filter(Threat.is_resolved == 0).count(),
        "critical":       db.query(Threat).filter(Threat.severity == ThreatSeverity.CRITICAL).count(),
        "high":           db.query(Threat).filter(Threat.severity == ThreatSeverity.HIGH).count(),
        "unread_alerts":  db.query(Alert).filter(Alert.is_read == False).count(),
    }