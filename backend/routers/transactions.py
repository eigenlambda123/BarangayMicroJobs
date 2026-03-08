from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session
from datetime import datetime
from uuid import UUID

from database import get_session
from models import User, JobPost, JobTransaction
from utils.auth_utils import get_current_user

router = APIRouter(prefix="/transactions", tags=["Transactions"])

@router.post("/accept/{job_id}", status_code=status.HTTP_201_CREATED)
def accept_job(
    job_id: UUID,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    # Fetch the job post
    job = session.get(JobPost, job_id)
    if not job:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Job not found")
    
    # Validate if the job is still open
    if job.status != "open":
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Job is not available for acceptance")
    
    # Prevent users from accepting their own job posts
    if job.poster_id == current_user.id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="You cannot accept your own job post")
    
    # Create the Transaction
    new_transaction = JobTransaction(
        job_id=job.id,
        provider_id=current_user.id, # The user who is accepting the job
        requester_id=job.poster_id, # The user who posted the job
        accepted_at=datetime.utcnow()
    )

    # Update the job status to "assigned"
    job.status = "assigned"

    session.add(new_transaction)
    session.add(job)
    session.commit()
    session.refresh(new_transaction)

    return {"message": "Job accepted successfully", "transaction_id": new_transaction.id}

