from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.db.database import get_db
from app.schemas.alert import AlertOut, AlertUpdate
from app.models.alert import Alert
from app.utils.dependencies import get_current_user
from app.models.user import User

router = APIRouter(prefix="/alerts", tags=["Alerts"])


@router.get("/", response_model=List[AlertOut])
def list_alerts(
    unread_only: bool = False,
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    q = db.query(Alert).order_by(Alert.sent_at.desc())
    if unread_only:
        q = q.filter(Alert.is_read == False)
    return q.offset(skip).limit(limit).all()


@router.patch("/{alert_id}", response_model=AlertOut)
def update_alert(
    alert_id: int,
    payload: AlertUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    alert = db.query(Alert).filter(Alert.id == alert_id).first()
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    alert.is_read = payload.is_read
    db.commit()
    db.refresh(alert)
    return alert


@router.get("/stats/summary")
def alert_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    total  = db.query(Alert).count()
    unread = db.query(Alert).filter(Alert.is_read == False).count()
    return {"total": total, "unread": unread, "read": total - unread}