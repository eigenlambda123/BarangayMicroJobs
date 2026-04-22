from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File, Form, status
from sqlmodel import Session, select
from typing import List, Optional
from datetime import datetime
from uuid import UUID
from sqlalchemy import func

from database import get_session
from models import JobPost, User, JobTransaction, TransactionStatus
from schemas.jobs import JobCreateRequest, UpdateJobRequest
from utils.auth_utils import get_current_user
from utils.file_uploads import save_uploaded_image
from utils.locations import is_valid_location

router = APIRouter(prefix="/jobs", tags=["Jobs"])


def _parse_csv_terms(value: Optional[str]) -> List[str]:
    if not value:
        return []
    return [term.strip().lower() for term in value.split(",") if term.strip()]


def _contains_any_term(text: str, terms: List[str]) -> bool:
    lowered_text = text.lower()
    return any(term in lowered_text for term in terms)

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


@router.post("/create-with-image", status_code=status.HTTP_201_CREATED)
def create_job_post_with_image(
    title: str = Form(...),
    description: str = Form(...),
    location: str = Form(...),
    salary: float = Form(...),
    image: Optional[UploadFile] = File(default=None),
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    if current_user.role != "resident":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only residents can post jobs",
        )

    if not is_valid_location(location):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid location: {location}. Must be a valid barangay in Lucena City.",
        )

    image_path: Optional[str] = None
    if image is not None:
        image_path = save_uploaded_image(image, "jobs")

    new_job = JobPost(
        poster_id=current_user.id,
        title=title,
        description=description,
        location=location,
        salary=salary,
        image=image_path,
        last_modified=datetime.utcnow(),
    )

    session.add(new_job)
    current_user.jobs_posted += 1
    session.add(current_user)

    session.commit()
    session.refresh(new_job)

    return {"message": "Job posted successfully", "job_id": new_job.id}

@router.get("/", response_model=List[JobPost])
def get_all_jobs(
    q: Optional[str] = Query(default=None, description="Search text for title/description"),
    location: Optional[str] = Query(default=None, description="Filter by exact location"),
    status_value: Optional[str] = Query(default=None, alias="status", description="Filter by job status (open, assigned, completed)"),
    min_salary: Optional[float] = Query(default=None, ge=0),
    max_salary: Optional[float] = Query(default=None, ge=0),
    poster_id: Optional[UUID] = Query(default=None, description="Filter jobs by poster"),
    skills: Optional[str] = Query(default=None, description="Comma-separated skill keywords matched against title/description"),
    session: Session = Depends(get_session),
):
    statement = select(JobPost)

    if location:
        statement = statement.where(func.lower(JobPost.location) == location.lower())

    if status_value:
        statement = statement.where(func.lower(JobPost.status) == status_value.lower())

    if min_salary is not None:
        statement = statement.where(JobPost.salary >= min_salary)

    if max_salary is not None:
        statement = statement.where(JobPost.salary <= max_salary)

    if poster_id is not None:
        statement = statement.where(JobPost.poster_id == poster_id)

    if q:
        like_query = f"%{q.lower()}%"
        statement = statement.where(
            func.lower(JobPost.title).like(like_query)
            | func.lower(JobPost.description).like(like_query)
        )

    statement = statement.order_by(JobPost.last_modified.desc())
    jobs = session.exec(statement).all()

    skill_terms = _parse_csv_terms(skills)
    if skill_terms:
        jobs = [
            job for job in jobs
            if _contains_any_term(f"{job.title} {job.description}", skill_terms)
        ]

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
    