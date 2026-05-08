from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from app.models.incident import IncidentStatus


class IncidentOut(BaseModel):
    id: int
    incident_id: str
    title: str
    description: Optional[str]
    status: IncidentStatus
    assignee: Optional[str]
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class IncidentUpdate(BaseModel):
    status: Optional[IncidentStatus] = None
    assignee: Optional[str] = None


class IncidentCreate(BaseModel):
    title: str
    description: Optional[str] = None