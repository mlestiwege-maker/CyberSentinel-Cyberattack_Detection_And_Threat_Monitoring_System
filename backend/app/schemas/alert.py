from pydantic import BaseModel
from datetime import datetime


class AlertOut(BaseModel):
    id:        int
    threat_id: int
    message:   str
    channel:   str
    is_read:   bool
    sent_at:   datetime

    model_config = {"from_attributes": True}


class AlertUpdate(BaseModel):
    is_read: bool