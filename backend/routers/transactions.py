from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from datetime import datetime
from uuid import UUID


from database import get_session
from models import User, JobPost, JobTransaction, TransactionStatus
from schemas.transactions import ApplicantsInfo
from utils.auth_utils import get_current_user

router = APIRouter(prefix="/transactions", tags=["Transactions"])

@router.post("/apply/{job_id}")
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

@router.patch("/hire/{transaction_id}")
def hire_provider(
    transaction_id: UUID,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    # Get the transaction
    transaction = session.get(JobTransaction, transaction_id)

    # Ensure the transaction exists and belongs to the current user as requester
    if not transaction or transaction.requester_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Transaction not found")
    
    # Udpate statuses
    transaction.status = TransactionStatus.HIRED
    job = session.get(JobPost, transaction.job_id)
    job.status = "assigned"

    # TODO: Reject other applications for the same job

    session.add(transaction)
    session.add(job)
    session.commit()
    return {"message": "Provider hired successfully", "transaction_id": transaction.id}

@router.get("/{job_id}/applicants")
def get_applicants(
    job_id: UUID,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    # Get the job post
    job = session.get(JobPost, job_id)
    if not job or job.poster_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Job not found")

    # Get all transactions for the job
    statement = select(JobTransaction).where(JobTransaction.job_id == job_id)
    transactions = session.exec(statement).all()

    applicants = []
    for transaction in transactions:
        provider = session.get(User, transaction.provider_id)
        applicants.append(ApplicantsInfo(
            id=provider.id,
            name=provider.full_name,
            rating=0,  # TODO: Calculate average rating for the provider
            phone_number=provider.phone_number
        ))

    return {"applicants": applicants}

# TODO: Add endpoints for completing jobs, leaving reviews, handling cancellations, Status of the job the provider applied for, etc.