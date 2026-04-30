import os

from sqlalchemy import inspect, text
from sqlmodel import Session, SQLModel, create_engine

# Local fallback for development when DATABASE_URL is not set.
SQLITE_URL = "sqlite:///./barangay_microjobs.db"

# Render provides DATABASE_URL automatically for managed PostgreSQL services.
DATABASE_URL = os.getenv("DATABASE_URL", SQLITE_URL)
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

USE_SQLITE = DATABASE_URL.startswith("sqlite")
connect_args = {"check_same_thread": False} if USE_SQLITE else {}

engine = create_engine(DATABASE_URL, echo=True, connect_args=connect_args)

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)

    inspector = inspect(engine)
    table_names = set(inspector.get_table_names())
    if "jobtransaction" not in table_names:
        return

    columns = {column["name"] for column in inspector.get_columns("jobtransaction")}
    statements = []

    if "requester_canceled" not in columns:
        statements.append(
            "ALTER TABLE jobtransaction ADD COLUMN requester_canceled BOOLEAN NOT NULL DEFAULT 0"
        )

    if "provider_canceled" not in columns:
        statements.append(
            "ALTER TABLE jobtransaction ADD COLUMN provider_canceled BOOLEAN NOT NULL DEFAULT 0"
        )

    if not statements:
        return

    with engine.begin() as connection:
        for statement in statements:
            connection.execute(text(statement))

def get_session():
    with Session(engine) as session:
        yield session