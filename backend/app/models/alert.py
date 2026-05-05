from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from app.db.database import Base


class Alert(Base):
    __tablename__ = "alerts"

    id        = Column(Integer, primary_key=True, index=True)
    threat_id = Column(Integer, ForeignKey("threats.id"), nullable=False)
    message   = Column(String(500), nullable=False)
    channel   = Column(String(50), default="dashboard")
    is_read   = Column(Boolean, default=False)
    sent_at   = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))