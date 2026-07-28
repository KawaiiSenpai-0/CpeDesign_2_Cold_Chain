from sqlalchemy import Column, Integer, Float, String, DateTime
from datetime import datetime

from .database import Base


class SensorReading(Base):
    __tablename__ = "sensor_readings"

    id = Column(Integer, primary_key=True, index=True)

    temperature = Column(Float)

    humidity = Column(Float)

    co2 = Column(Float)

    # Final AI Decision
    prediction = Column(String)

    # LSTM
    lstm_prediction = Column(String)
    lstm_confidence = Column(Float)

    # Random Forest
    rf_prediction = Column(String)
    rf_confidence = Column(Float)

    timestamp = Column(DateTime, default=datetime.utcnow)