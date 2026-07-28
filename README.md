# ColdSense

ColdSense monitors cold-chain sensor readings from ESP32 devices and uses LSTM
and Random Forest models to classify produce as **Fresh**, **At Risk**, or
**Spoiled**.

## Components

- Flutter application: dashboard, history charts, device status, and settings
- FastAPI backend: sensor ingestion, inference, and REST API
- SQLite: sensor and device records
- ESP32: posts sensor readings to `POST /sensor-data`

## Run the backend

```powershell
cd backend
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

The database is always stored at `backend/coldsense.db`, regardless of the
directory from which Uvicorn is started.

For a physical phone, use the computer's LAN address in the app's **Settings**
screen, for example `http://192.168.1.6:8000`. The backend must be started with
`--host 0.0.0.0` and the computer firewall must allow port 8000.

## API

- `POST /sensor-data` accepts the existing ESP32 payload.
- `GET /latest` returns the newest reading.
- `GET /history?skip=0&limit=500` returns up to 500 newest readings in
  chronological order.
- `GET /device-info` returns the most recently seen device.
- `GET /device-info?device_name=...` returns a particular device.

Browser clients are allowed by default during local development. Set
`CORS_ORIGINS` to a comma-separated list of trusted origins before deployment.
Set `COLDSENSE_API_KEY` to require ESP32 requests to include its value in the
`X-API-Key` header; leaving it unset preserves the existing ESP32 payload.
