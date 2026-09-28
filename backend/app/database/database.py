import os
from pathlib import Path

from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import sessionmaker

BACKEND_DIR = Path(__file__).resolve().parents[2]
LOCAL_DATABASE_URL = f"sqlite:///{(BACKEND_DIR / 'coldsense.db').as_posix()}"


def _database_url() -> str:
    """Use a hosted database when supplied, otherwise preserve local SQLite."""
    configured_url = os.getenv("DATABASE_URL", "").strip()
    if not configured_url:
        return LOCAL_DATABASE_URL

    # Render may supply the legacy postgres:// scheme. SQLAlchemy needs an
    # explicit psycopg driver URL for the PostgreSQL driver in requirements.txt.
    if configured_url.startswith("postgres://"):
        return f"postgresql+psycopg://{configured_url.removeprefix('postgres://')}"
    if configured_url.startswith("postgresql://"):
        return f"postgresql+psycopg://{configured_url.removeprefix('postgresql://')}"
    return configured_url


DATABASE_URL = _database_url()

engine_options = {}
if DATABASE_URL.startswith("sqlite"):
    engine_options["connect_args"] = {"check_same_thread": False}

engine = create_engine(
    DATABASE_URL,
    **engine_options,
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)

Base = declarative_base()
