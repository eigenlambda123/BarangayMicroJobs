from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from typing import List
from datetime import datetime

from database import get_session
from models import JobPost, User
from schemas.jobs import JobCreateRequest
from utils.auth_utils import get_current_user

router = APIRouter(prefix="/jobs", tags=["jobs"])

@router.post("/", status_code=status.HTTP_201_CREATED)
def create_job_post(
    job: JobCreateRequest,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    # Only allow residents to post jobs
    if current_user.role != "resident":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only residents can post jobs")

    new_job = JobPost(
        poster_id=current_user.id,
        title=job.title,
        description=job.description,
        location=job.location,
        salary=job.salary,
        last_modified=datetime.utcnow()
    )

    session.add(new_job)
    session.commit()
    session.refresh(new_job)

    return {"message": "Job posted successfully", "job_id": new_job.id}

@router.get("/", response_model=List[JobPost])
def get_all_jobs(session: Session = Depends(get_session)):
    statement = select(JobPost)
    jobs = session.exec(statement).all()
    return jobs
    