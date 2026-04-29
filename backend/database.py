from sqlmodel import create_engine, SQLModel, Session
from sqlalchemy.orm import sessionmaker
from sqlalchemy import inspect, text

# Set this to True to use SQLite for local development
USE_SQLITE = True

# File path for SQLite
SQLITE_URL = "sqlite:///./barangay_microjobs.db"
# Connection string for PostgreSQL
POSTGRES_URL = "postgresql://user:password@localhost:5432/barangay_microjobs_db"

# Select the URL based on switch
DATABASE_URL = SQLITE_URL if USE_SQLITE else POSTGRES_URL

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