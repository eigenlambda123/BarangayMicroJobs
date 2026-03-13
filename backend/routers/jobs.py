from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from typing import List
from datetime import datetime
from uuid import UUID

from database import get_session
from models import JobPost, User
from schemas.jobs import JobCreateRequest
from utils.auth_utils import get_current_user

router = APIRouter(prefix="/jobs", tags=["Jobs"])

@router.post("/create", status_code=status.HTTP_201_CREATED)
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
        image=job.image,
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

@router.delete("/{job_id}")
def delete_job_post(
    job_id: UUID,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    job = session.get(JobPost, job_id)
    if not job:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Job not found")
    
    if job.poster_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You can only delete your own job posts")
    
    session.delete(job)
    session.commit()
    
    return {"message": "Job post deleted successfully"}
    