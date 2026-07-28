from pydantic import BaseModel, Field


class SensorData(BaseModel):
    temperature: float = Field(ge=-50, le=100)
    humidity: float = Field(ge=0, le=100)
    co2: int = Field(ge=0, le=50000)

    device_name: str
    ip_address: str
    wifi_name: str
    firmware_version: str
