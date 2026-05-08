from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.models.user import User
from app.utils.dependencies import get_current_user

router = APIRouter(prefix="/reports", tags=["Reports"])


@router.get("/")
def list_reports(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return [
        {"id": 1, "title": "Daily Threat Report", "format": "PDF", "generatedAt": "Generated 10:00 AM"},
        {"id": 2, "title": "Weekly Incident Summary", "format": "PDF", "generatedAt": "Generated Monday"},
        {"id": 3, "title": "Executive Dashboard Export", "format": "CSV", "generatedAt": "Generated Today"},
        {"id": 4, "title": "SMS Activity Report", "format": "CSV", "generatedAt": "Generated Today"},
    ]


@router.post("/export")
def export_report(
    report_type: str = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return {"success": True, "message": f"Report exported to /CyberSentinel/reports/", "downloadUrl": "/reports/download/latest"}


@router.get("/export/all")
def export_all_reports(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return {"success": True, "message": "All reports exported successfully", "count": 4}