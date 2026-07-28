from sqlalchemy import Column, Integer, String, Boolean, DateTime
from datetime import datetime

from .database import Base


class Device(Base):
    __tablename__ = "devices"

    id = Column(Integer, primary_key=True, index=True)

    device_name = Column(String, unique=True)

    ip_address = Column(String)

    wifi_name = Column(String)

    firmware_version = Column(String)

    connected = Column(Boolean, default=True)

    last_seen = Column(DateTime, default=datetime.utcnow)