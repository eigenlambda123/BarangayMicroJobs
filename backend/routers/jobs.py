from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from typing import List
from datetime import datetime
from uuid import UUID

from database import get_session
from models import JobPost, User, JobTransaction, TransactionStatus
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
    
    # Update user's jobs_posted count
    current_user.jobs_posted += 1
    session.add(current_user)
    
    session.commit()
    session.refresh(new_job)

    return {"message": "Job posted successfully", "job_id": new_job.id}

@router.get("/", response_model=List[JobPost])
def get_all_jobs(session: Session = Depends(get_session)):
    statement = select(JobPost)
    jobs = session.exec(statement).all()
    return jobs

@router.get("/{job_id}", response_model=JobPost)
def get_job_post(
    job_id: UUID,
    session: Session = Depends(get_session)
):
    job = session.get(JobPost, job_id)
    if not job:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Job not found")
    return job

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

@router.get("/user/{user_id}")
def get_user_jobs(
    user_id: UUID,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    # Get jobs posted by the user
    posted_jobs_statement = select(JobPost).where(JobPost.poster_id == user_id)
    posted_jobs = session.exec(posted_jobs_statement).all()
    
    # Get jobs done by the user (completed transactions where user is provider)
    completed_transactions_statement = select(JobTransaction).where(
        JobTransaction.provider_id == user_id,
        JobTransaction.status == TransactionStatus.COMPLETED
    )
    completed_transactions = session.exec(completed_transactions_statement).all()
    
    # Get the job details for completed transactions
    jobs_done = []
    for transaction in completed_transactions:
        job = session.get(JobPost, transaction.job_id)
        if job:
            jobs_done.append(job)
    
    return {
        "posted_jobs": posted_jobs,
        "jobs_done": jobs_done,
        "stats": {
            "jobs_posted_count": len(posted_jobs),
            "jobs_done_count": len(jobs_done)
        }
    }
    