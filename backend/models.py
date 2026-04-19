from datetime import datetime
from typing import Optional, List
from uuid import UUID, uuid4
from sqlmodel import Field, SQLModel, Relationship, Column
from sqlalchemy import JSON
from enum import Enum

class User(SQLModel, table=True):
    # Basic User Informations
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    full_name: str 
    phone_number: str = Field(unique=True)

    # Security/Indentity
    is_verified: bool = Field(default=True)
    role: str = Field(default="resident") # "admin" or "resident"
    hashed_password: str

    # Profile Information
    profile_image: Optional[str] = None
    email: Optional[str] = None
    location: Optional[str] = None
    skills: Optional[List[str]] = Field(default=None, sa_column=Column(JSON))

    # Profile Stats
    rating: float = Field(default=0.0) 
    review_count: int = Field(default=0) 
    jobs_done: int = Field(default=0)  
    jobs_posted: int = Field(default=0) 
    total_earned: float = Field(default=0.0) 
    # Relationships
    # 1. As a Job Poster
    posted_jobs: List["JobPost"] = Relationship(back_populates="poster")

class JobPost(SQLModel, table=True):
    # Basic JobPost Informations
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    poster_id: UUID = Field(foreign_key="user.id")
    title: str
    description: str
    location: str
    salary: float
    image: Optional[str] = None
    applicants_count: int = Field(default=0)
    status: str = Field(default="open") # "open", "assigned", "completed"

    # Sync and Conflict Resolution fields
    last_modified: datetime
    is_synced: bool = Field(default=False)

    # Relationship
    poster: User = Relationship(back_populates="posted_jobs")

class TransactionStatus(str, Enum):
    APPLIED = "applied"
    HIRED = "hired"
    COMPLETED = "completed"
    CANCELED = "canceled"

class JobTransaction(SQLModel, table=True):
    # Basic JobTransaction Informations
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    job_id: UUID = Field(foreign_key="jobpost.id")
    provider_id: UUID = Field(foreign_key="user.id")
    requester_id: UUID = Field(foreign_key="user.id")
    accepted_at: datetime = Field(default_factory=datetime.utcnow)
    completed_at: Optional[datetime]
    status: TransactionStatus = Field(default=TransactionStatus.APPLIED)
    
    # Dual completion flags
    requester_completed: bool = Field(default=False)
    provider_completed: bool = Field(default=False)

class Rating(SQLModel, table=True):
    # Basic Rating Informations
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    transaction_id: UUID = Field(foreign_key="jobtransaction.id")
    job_id: UUID = Field(foreign_key="jobpost.id")

    # Job poster rates the service provider
    rater_id: UUID = Field(foreign_key="user.id")  # Job poster
    target_id: UUID = Field(foreign_key="user.id")  # Service provider

    score: int = Field(ge=1, le=5)
    comment: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
