from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from typing import List
from datetime import datetime
from uuid import UUID

from database import get_session
from models import JobPost, User, JobTransaction, TransactionStatus
from schemas.jobs import JobCreateRequest, UpdateJobRequest
from utils.auth_utils import get_current_user

router = APIRouter(prefix="/jobs", tags=["Jobs"])

def get_jobs_by_poster(session: Session, poster_id: UUID) -> List[JobPost]:
    """Get all jobs posted by a specific user"""
    statement = select(JobPost).where(JobPost.poster_id == poster_id)
    return session.exec(statement).all()

def get_completed_jobs_by_provider(session: Session, provider_id: UUID) -> List[JobPost]:
    """Get all completed jobs where user was the provider"""
    completed_transactions = session.exec(
        select(JobTransaction).where(
            JobTransaction.provider_id == provider_id,
            JobTransaction.status == TransactionStatus.COMPLETED
        )
    ).all()
    
    jobs = []
    for transaction in completed_transactions:
        job = session.get(JobPost, transaction.job_id)
        if job:
            jobs.append(job)
    return jobs

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

@router.put("/{job_id}")
def update_job_post(
    job_id: UUID,
    job_data: UpdateJobRequest,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    """Update a job post (only by the poster)"""
    job = session.get(JobPost, job_id)
    if not job:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Job not found")
    
    if job.poster_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You can only edit your own job posts")
    
    # Update fields only if provided
    if job_data.title is not None:
        job.title = job_data.title
    
    if job_data.description is not None:
        job.description = job_data.description
    
    if job_data.location is not None:
        job.location = job_data.location
    
    if job_data.salary is not None:
        job.salary = job_data.salary
    
    if job_data.image is not None:
        job.image = job_data.image
    
    job.last_modified = datetime.utcnow()
    
    session.add(job)
    session.commit()
    session.refresh(job)
    
    return {"message": "Job post updated successfully", "job": job}

@router.get("/user/{user_id}")
def get_user_jobs(
    user_id: UUID,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    # Get jobs posted by the user
    posted_jobs = get_jobs_by_poster(session, user_id)
    
    # Get jobs done by the user (completed transactions where user is provider)
    jobs_done = get_completed_jobs_by_provider(session, user_id)
    
    return {
        "posted_jobs": posted_jobs,
        "jobs_done": jobs_done,
        "stats": {
            "jobs_posted_count": len(posted_jobs),
            "jobs_done_count": len(jobs_done)
        }
    }
    