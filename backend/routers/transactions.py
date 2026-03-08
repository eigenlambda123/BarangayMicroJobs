from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session
from datetime import datetime
from uuid import UUID

from database import get_session
from models import User, JobPost, JobTransaction, TransactionStatus
from utils.auth_utils import get_current_user

router = APIRouter(prefix="/transactions", tags=["Transactions"])

@router.post("apply/{job_id}")
def apply_for_job(
    job_id: UUID,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    # Get the job post
    job = session.get(JobPost, job_id)
    if not job:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Job not available")

    # Create the transaction
    transaction = JobTransaction(
        job_id=job_id,
        provider_id=current_user.id,
        requester_id=job.poster_id,
        status=TransactionStatus.APPLIED,
        accepted_at=datetime.utcnow()
    )

    session.add(transaction)
    session.commit()
    session.refresh(transaction)

    return {"message": "Application Submitted"}