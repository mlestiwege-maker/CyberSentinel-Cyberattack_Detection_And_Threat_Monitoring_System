from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, DateTime, Enum
from app.db.database import Base
import enum


class IncidentStatus(str, enum.Enum):
    OPEN = "Open"
    IN_PROGRESS = "In Progress"
    RESOLVED = "Resolved"


class Incident(Base):
    __tablename__ = "incidents"

    id = Column(Integer, primary_key=True, index=True)
    incident_id = Column(String(50), unique=True, index=True)
    title = Column(String(200), nullable=False)
    description = Column(String(500), nullable=True)
    status = Column(Enum(IncidentStatus), default=IncidentStatus.OPEN)
    assignee = Column(String(100), nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))