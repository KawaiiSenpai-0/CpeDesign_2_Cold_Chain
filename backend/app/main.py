import os
from datetime import datetime

from fastapi import Depends, FastAPI, Header, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from app.database.database import engine, SessionLocal
from app.database.models import Base, SensorReading
from app.database.device_model import Device
from app.models.schemas import SensorData

# Initialize database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="ColdSense API",
    version="1.0.0",
)

cors_origins = [
    origin.strip()
    for origin in os.getenv("CORS_ORIGINS", "*").split(",")
    if origin.strip()
]
sensor_api_key = os.getenv("COLDSENSE_API_KEY")
app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def verify_sensor_api_key(x_api_key: str | None = Header(default=None)):
    """Require an API key only when COLDSENSE_API_KEY is configured."""
    if sensor_api_key and x_api_key != sensor_api_key:
        raise HTTPException(status_code=401, detail="Invalid sensor API key")


def serialize_reading(reading: SensorReading):
    """Return the single public response shape used by all sensor endpoints."""
    return {
        "temperature": reading.temperature,
        "humidity": reading.humidity,
        "co2": reading.co2,
        # Legacy prediction fields remain nullable for backward compatibility.
        "prediction": reading.prediction,
        "lstm_prediction": reading.lstm_prediction,
        "lstm_confidence": reading.lstm_confidence,
        "rf_prediction": reading.rf_prediction,
        "rf_confidence": reading.rf_confidence,
        "timestamp": reading.timestamp.isoformat(),
    }


@app.get("/")
def root():
    return {"message": "ColdSense Backend Running"}


@app.post("/sensor-data")
def receive_sensor_data(
    data: SensorData,
    _: None = Depends(verify_sensor_api_key),
    db: Session = Depends(get_db),
):
    # Store raw sensor data. ML inference is performed by Flutter.
    reading = SensorReading(
        temperature=data.temperature,
        humidity=data.humidity,
        co2=data.co2,
    )
    db.add(reading)

    # =====================================
    # 3. Update Device Info
    # =====================================
    device = (
        db.query(Device)
        .filter(Device.device_name == data.device_name)
        .first()
    )

    if device is None:
        device = Device(device_name=data.device_name)
        db.add(device)

    device.ip_address = data.ip_address
    device.wifi_name = data.wifi_name
    device.firmware_version = data.firmware_version
    device.connected = True
    device.last_seen = datetime.utcnow()

    # Commit transactions
    db.commit()
    db.refresh(reading)

    return serialize_reading(reading)


@app.get("/latest")
def get_latest_data(db: Session = Depends(get_db)):

    reading = (
        db.query(SensorReading)
        .order_by(SensorReading.id.desc())
        .first()
    )

    if reading is None:
        return {
            "message": "No sensor data available"
        }

    return serialize_reading(reading)


@app.get("/history")
def get_history(
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=500, ge=1, le=5000),
    db: Session = Depends(get_db),
):

    readings = (
        db.query(SensorReading)
        .order_by(SensorReading.timestamp.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )

    return [serialize_reading(reading) for reading in reversed(readings)]


@app.get("/health")
def health():
    return {
        "status": "online",
        "backend": "FastAPI",
        "database": "SQLite",
        "version": "1.0.0",
    }


@app.get("/device-info")
def device_info(
    device_name: str | None = None,
    db: Session = Depends(get_db),
):

    query = db.query(Device)
    if device_name:
        query = query.filter(Device.device_name == device_name)
    device = query.order_by(Device.last_seen.desc()).first()

    if device is None:
        return {
            "device_name": "No Device",
            "ip_address": "--",
            "wifi_name": "--",
            "firmware_version": "--",
            "connected": False,
            "dht22": False,
            "mhz19c": False,
            "bme680": False,
            "last_update": None,
        }

    # Determine if device is still online
    now = datetime.utcnow()

    seconds_since_seen = (
        now - device.last_seen
    ).total_seconds()

    is_connected = seconds_since_seen <= 15

    return {
        "device_name": device.device_name,
        "ip_address": device.ip_address,
        "wifi_name": device.wifi_name,
        "firmware_version": device.firmware_version,
        "connected": is_connected,

        # Installed sensors
        "dht22": True,
        "mhz19c": True,
        "bme680": False,

        "last_update": device.last_seen.isoformat(),
    }
