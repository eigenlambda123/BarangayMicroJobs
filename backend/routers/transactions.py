from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from datetime import datetime
from uuid import UUID


from database import get_session
from models import User, JobPost, JobTransaction, TransactionStatus, Rating
from schemas.transactions import ApplicantsInfo
from schemas.ratings import RatingRequest
from utils.auth_utils import get_current_user

router = APIRouter(prefix="/transactions", tags=["Transactions"])

def get_job_safe(session: Session, job_id: UUID) -> JobPost:
    """Safely get job by ID, raises 404 if not found"""
    job = session.get(JobPost, job_id)
    if not job:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Job not found")
    return job

def get_user_safe(session: Session, user_id: UUID) -> User:
    """Safely get user by ID, raises 404 if not found"""
    user = session.get(User, user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user

def get_transaction_safe(session: Session, transaction_id: UUID) -> JobTransaction:
    """Safely get transaction by ID, raises 404 if not found"""
    transaction = session.get(JobTransaction, transaction_id)
    if not transaction:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Transaction not found")
    return transaction

def build_transaction_data(transaction: JobTransaction, job: JobPost, provider: User, requester: User, current_user_id: UUID) -> dict:
    """Build transaction data dictionary"""
    return {
        "id": transaction.id,
        "job": {
            "id": job.id,
            "title": job.title,
            "salary": job.salary,
            "location": job.location,
            "status": job.status,
        },
        "provider": {
            "id": provider.id,
            "name": provider.full_name,
        },
        "requester": {
            "id": requester.id,
            "name": requester.full_name,
        },
        "status": transaction.status.value,
        "accepted_at": transaction.accepted_at,
        "completed_at": transaction.completed_at,
        "is_requester": transaction.requester_id == current_user_id,
        "requester_completed": transaction.requester_completed,
        "provider_completed": transaction.provider_completed,
    }

@router.get("/me")
def get_my_transactions(
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    # Get transactions where user is requester or provider
    statement = select(JobTransaction).where(
        (JobTransaction.requester_id == current_user.id) | (JobTransaction.provider_id == current_user.id)
    )
    transactions = session.exec(statement).all()

    result = []
    for transaction in transactions:
        job = session.get(JobPost, transaction.job_id)
        provider = session.get(User, transaction.provider_id)
        requester = session.get(User, transaction.requester_id)
        
        if job is None or provider is None or requester is None:
            continue
        
        result.append(build_transaction_data(transaction, job, provider, requester, current_user.id))

    return {"transactions": result}

@router.post("/apply/{job_id}")
def apply_for_job(
    job_id: UUID,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    # Get the job post
    job = get_job_safe(session, job_id)

    # Check if user is trying to apply to their own job
    if job.poster_id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="You cannot apply to your own job"
        )

    # Check if user has already applied to this job
    existing_application = session.exec(
        select(JobTransaction).where(
            JobTransaction.job_id == job_id,
            JobTransaction.provider_id == current_user.id
        )
    ).first()
    
    if existing_application:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="You have already applied to this job"
        )

    # Create the transaction
    transaction = JobTransaction(
        job_id=job_id,
        provider_id=current_user.id,
        requester_id=job.poster_id,
        status=TransactionStatus.APPLIED,
        accepted_at=datetime.utcnow()
    )

    # Increment applicants count
    job.applicants_count += 1

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
    transaction = get_transaction_safe(session, transaction_id)

    # Ensure the transaction exists and belongs to the current user as requester
    if transaction.requester_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Transaction not found")
    
    # Udpate statuses
    transaction.status = TransactionStatus.HIRED
    job = get_job_safe(session, transaction.job_id)
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
    job = get_job_safe(session, job_id)
    if job.poster_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Job not found")

    # Get all transactions for the job
    statement = select(JobTransaction).where(JobTransaction.job_id == job_id)
    transactions = session.exec(statement).all()

    applicants = []
    for transaction in transactions:
        provider = get_user_safe(session, transaction.provider_id)
        applicants.append(ApplicantsInfo(
            id=provider.id,
            name=provider.full_name,
            rating=0,  # TODO: Calculate average rating for the provider
            phone_number=provider.phone_number
        ))

    return {"applicants": applicants}

@router.patch("/complete/{transaction_id}")
def mark_job_as_completed(
    transaction_id: UUID,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    # Get the transaction
    transaction = get_transaction_safe(session, transaction_id)

    # Only the requester or provider can mark the job as completed
    if transaction.requester_id != current_user.id and transaction.provider_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only the requester or provider can mark the job as completed")

    # Set completion flag based on who's marking it as completed
    if transaction.requester_id == current_user.id:
        transaction.requester_completed = True
    else:
        transaction.provider_completed = True

    # Only mark as completed if both have confirmed
    if transaction.requester_completed and transaction.provider_completed:
        transaction.status = TransactionStatus.COMPLETED
        transaction.completed_at = datetime.utcnow()
        
        job = get_job_safe(session, transaction.job_id)
        job.status = "completed"
        session.add(job)
        
        # Update user stats
        provider = get_user_safe(session, transaction.provider_id)
        provider.jobs_done += 1
        provider.total_earned += job.salary
        session.add(provider)
        
        session.add(transaction)
        session.commit()
        return {"message": "Job marked as completed by both parties", "transaction_id": transaction.id}
    else:
        session.add(transaction)
        session.commit()
        return {"message": "Completion marked by one party. Waiting for the other party to confirm.", "transaction_id": transaction.id}

@router.patch("/cancel/{transaction_id}")
def cancel_transaction(
    transaction_id: UUID,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    # Get the transaction
    transaction = get_transaction_safe(session, transaction_id)

    # Only the requester or provider can cancel the transaction
    if transaction.requester_id != current_user.id and transaction.provider_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only the requester or provider can cancel the transaction")

    # Check if transaction is in a cancellable state (not completed)
    if transaction.status == TransactionStatus.COMPLETED:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot cancel a completed transaction")

    # Update transaction status
    transaction.status = TransactionStatus.CANCELED
    
    # Update job status back to open if it was assigned
    job = get_job_safe(session, transaction.job_id)
    if job.status == "assigned":
        job.status = "open"
        # Decrement applicants count since this application is being canceled
        if job.applicants_count > 0:
            job.applicants_count -= 1
        session.add(job)

    session.add(transaction)
    session.commit()
    
    return {"message": "Transaction canceled successfully", "transaction_id": transaction.id}

# TODO: Add endpoints for handling cancellations, Status of the job the provider applied for, etc.