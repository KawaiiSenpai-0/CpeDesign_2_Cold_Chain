# ColdSense

ColdSense monitors cold-chain sensor readings from ESP32 devices and uses local
LSTM and Random Forest models to classify produce as **Fresh**, **Warning**, or
**Critical**.

## Components

- Flutter application: dashboard, history charts, device status, and settings
- FastAPI backend: sensor ingestion, raw-data storage, and REST API
- Flutter mobile app: local LSTM, Random Forest, and 70/30 ensemble inference
- SQLite locally / managed PostgreSQL in cloud deployment: sensor and device records
- ESP32: posts sensor readings to `POST /sensor-data`

## Backend local development

```powershell
cd backend
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

When `DATABASE_URL` is not set, the backend uses the existing local SQLite
database at `backend/coldsense.db`, regardless of the directory from which
Uvicorn is started. Existing local database records are preserved.

For a physical phone, use the computer's LAN address in the app's **Settings**
screen, for example `http://192.168.1.6:8000`. The backend must be started with
`--host 0.0.0.0` and the computer firewall must allow port 8000.

## API

- `POST /sensor-data` accepts the existing ESP32 payload and stores raw readings.
- `GET /latest` returns the newest reading.
- `GET /history?skip=0&limit=500` returns up to 500 newest readings in
  chronological order.
- `GET /device-info` returns the most recently seen device.
- `GET /device-info?device_name=...` returns a particular device.

Browser clients are allowed by default during local development. Set
`CORS_ORIGINS` to a comma-separated list of trusted origins before deployment.
Set `COLDSENSE_API_KEY` to require ESP32 requests to include its value in the
`X-API-Key` header; leaving it unset preserves the existing ESP32 payload.

## Cloud deployment prerequisites (Render)

The repository includes `render.yaml` for a FastAPI web service rooted at
`backend`. Its start command is:

```text
uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

Create and attach a managed Render PostgreSQL database during the deployment
step, then configure the web service with these environment variables:

- `DATABASE_URL`: Render PostgreSQL connection URL. The backend also accepts
  Render's legacy `postgres://` form and normalizes it for SQLAlchemy/psycopg.
- `CORS_ORIGINS`: comma-separated trusted browser origins. Leave unset only
  for local development, where the existing wildcard behavior is preserved.
- `COLDSENSE_API_KEY`: optional secret required in the ESP32 `X-API-Key`
  header when configured.

Never commit database URLs containing credentials or API keys. Set them only
in Render's environment-variable/secret settings. No Render database or
service is created by this repository configuration.

`Base.metadata.create_all()` remains enabled for now. A separate approved
database-migration step is required before moving existing SQLite data into
PostgreSQL.

The original backend ML implementation and model artifacts remain available as
the reference and rollback implementation. The production mobile model is
`ColdGuard-AI-v1` with LSTM weight `0.70` and Random Forest weight `0.30`.
