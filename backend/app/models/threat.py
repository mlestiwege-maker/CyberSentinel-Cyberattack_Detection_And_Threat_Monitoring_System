from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Float, DateTime, Enum, JSON
from app.db.database import Base
import enum


class ThreatSeverity(str, enum.Enum):
    LOW      = "low"
    MEDIUM   = "medium"
    HIGH     = "high"
    CRITICAL = "critical"


class ThreatType(str, enum.Enum):
    DDOS        = "ddos"
    RANSOMWARE  = "ransomware"
    BRUTE_FORCE = "brute_force"
    PORT_SCAN   = "port_scan"
    ANOMALY     = "anomaly"
    NORMAL      = "normal"


class Threat(Base):
    __tablename__ = "threats"

    id             = Column(Integer, primary_key=True, index=True)
    source_ip      = Column(String(45), nullable=False, index=True)
    destination_ip = Column(String(45), nullable=True)
    protocol       = Column(String(20), nullable=True)
    threat_type    = Column(Enum(ThreatType), default=ThreatType.ANOMALY)
    severity       = Column(Enum(ThreatSeverity), default=ThreatSeverity.MEDIUM)
    confidence     = Column(Float, nullable=False)
    features       = Column(JSON, nullable=True)
    description    = Column(String(500), nullable=True)
    is_resolved    = Column(Integer, default=0)
    detected_at    = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    resolved_at    = Column(DateTime(timezone=True), nullable=True)