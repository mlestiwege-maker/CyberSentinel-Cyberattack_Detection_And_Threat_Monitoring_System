from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.db.database import get_db
from app.schemas.threat import ThreatDetectRequest, ThreatDetectResponse, ThreatOut
from app.services import threat_service
from app.services.ml_service import ml_service
from app.utils.dependencies import get_current_user
from app.models.user import User

router = APIRouter(prefix="/threats", tags=["Threat Detection"])


@router.post("/detect", response_model=ThreatDetectResponse)
def detect_threat(
    payload: ThreatDetectRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    features_dict = payload.features.model_dump()
    result = ml_service.predict(features_dict)

    threat_id = None
    if result["is_threat"]:
        saved = threat_service.save_threat(db, result, features_dict)
        threat_id = saved.id

    severity_label = result["severity"].value if result["severity"] else "none"
    return ThreatDetectResponse(
        threat_type = result["threat_type"].value,
        severity    = severity_label,
        confidence  = round(result["confidence"], 4),
        is_threat   = result["is_threat"],
        message     = (
            f"⚠️ {result['threat_type'].value.upper()} detected — severity: {severity_label}"
            if result["is_threat"] else "✅ Traffic is normal"
        ),
        threat_id = threat_id,
    )


@router.get("/", response_model=List[ThreatOut])
def list_threats(
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return threat_service.get_threats(db, skip, limit)


@router.patch("/{threat_id}/resolve", response_model=ThreatOut)
def resolve(
    threat_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return threat_service.resolve_threat(db, threat_id)