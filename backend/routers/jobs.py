from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from typing import List
from datetime import datetime

from database import get_session
from models import JobPost, User
from utils.auth_utils import get_current_user

router = APIRouter(prefix="/jobs", tags=["jobs"])

# TODO: Add schema for request and response models for better validation and documentation
@router.post("/", status_code=status.HTTP_201_CREATED)
def create_job_post(
    job: JobPost,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    # Only allow verified users to create job posts
    if not current_user.is_verified:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User is not verified to create job posts."
        )
    
    # Check if a job post with the same ID already exists
    existing_jobs = session.get(JobPost, job.id)
    if existing_jobs:
        return existing_jobs
    
    job.poster_id = current_user.id
    job.last_modified = datetime.now()
    job.is_synced = True

    session.add(job)
    session.commit()
    session.refresh(job)
    return job
    