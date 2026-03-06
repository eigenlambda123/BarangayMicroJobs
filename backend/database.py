from sqlmodel import create_engine, SQLModel, Session
from sqlalchemy.orm import sessionmaker

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

def get_session():
    with Session(engine) as session:
        yield session