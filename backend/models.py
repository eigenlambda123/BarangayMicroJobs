from datetime import datetime
from typing import Optional, List
from uuid import UUID, uuid4
from sqlmodel import Field, SQLModel, Relationship

class User(SQLModel, table=True):
    # Basic User Informations
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    full_name: str 
    phone_number: str = Field(unique=True)

    # Security/Indentity
    is_verified: bool = Field(default=False)
    role: str = Field(default="resident") # "admin" or "resident"
    hashed_password: str

    # Relationships
    # 1. As a Job Poster
    posted_jobs: List["JobPost"] = Relationship(back_populates="poster")

    # 2. As a Service Provider
    tasks_accepted: List["JobTransaction"] = Relationship(back_populates="provider")

class JobPost(SQLModel, table=True):
    # Basic JobPost Informations
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    poster_id: UUID = Field(foreign_key="user.id")
    title: str
    description: str
    status: str = Field(default="open") # "open", "assigned", "completed"

    # Sync and Conflict Resolution fields
    last_modified: datetime
    is_synced: bool = Field(default=False)

    # Relationship
    poster: User = Relationship(back_populates="posted_jobs")

class JobTransaction(SQLModel, table=True):
    # Basic JobTransaction Informations
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    job_id: UUID = Field(foreign_key="jobpost.id")
    provider_id: UUID = Field(foreign_key="user.id")
    accepted_at: datetime = Field(default_factory=datetime.utcnow)
    completed_at: Optional[datetime]

    # Relationship
    provider: User = Relationship(back_populates="tasks_accepted")

class Rating(SQLModel, table=True):
    # Basic Rating Informations
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    job_id: UUID = Field(foreign_key="jobpost.id")

    # Who is giving the rating?
    rater_id: UUID = Field(foreign_key="user.id")
    # Who is receiving the rating?
    target_id: UUID = Field(foreign_key="user.id")

    score: int = Field(ge=1, le=5)
    comment: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
