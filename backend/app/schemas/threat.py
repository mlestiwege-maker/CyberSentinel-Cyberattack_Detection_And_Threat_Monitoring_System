from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional
from app.models.threat import ThreatSeverity, ThreatType


class NetworkFeatures(BaseModel):
    duration:       float
    protocol_type:  str
    src_bytes:      int
    dst_bytes:      int
    land:           int = 0
    wrong_fragment: int = 0
    urgent:         int = 0
    count:          int
    srv_count:      int
    source_ip:      str
    destination_ip: Optional[str] = None


class ThreatDetectRequest(BaseModel):
    features: NetworkFeatures


class ThreatOut(BaseModel):
    id:             int
    source_ip:      str
    destination_ip: Optional[str]
    threat_type:    ThreatType
    severity:       ThreatSeverity
    confidence:     float
    description:    Optional[str]
    is_resolved:    int
    detected_at:    datetime

    model_config = {"from_attributes": True}


class ThreatDetectResponse(BaseModel):
    threat_type: str
    severity:    str
    confidence:  float
    is_threat:   bool
    message:     str
    threat_id:   Optional[int] = None