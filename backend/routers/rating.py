from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from datetime import datetime
from uuid import UUID

from database import get_session
from models import User, JobPost, JobTransaction, TransactionStatus, Rating
from schemas.ratings import RatingRequest, RatingResponse
from utils.auth_utils import get_current_user

router = APIRouter(prefix="/ratings", tags=["Ratings"])


@router.post("/{transaction_id}/rate")
def rate_provider(
    transaction_id: UUID,
    rating_data: RatingRequest,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    # Get transaction
    transaction = session.get(JobTransaction, transaction_id)
    if not transaction:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Transaction not found")
    
    # Only the job poster (requester) can rate
    if transaction.requester_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only the job poster can rate the service provider")
    
    # Only allow rating if job is completed
    if transaction.status != TransactionStatus.COMPLETED:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Can only rate completed jobs")
    
    # Prevent duplicate ratings
    existing = session.exec(
        select(Rating).where(
            Rating.transaction_id == transaction_id,
            Rating.rater_id == current_user.id
        )
    ).first()
    if existing:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="You already rated this job")
    
    # Create rating
    rating = Rating(
        transaction_id=transaction_id,
        job_id=transaction.job_id,
        rater_id=current_user.id,
        target_id=transaction.provider_id,
        score=rating_data.score,
        comment=rating_data.comment
    )
    
    session.add(rating)
    session.commit()
    session.refresh(rating)
    
    return {
        "message": "Rating submitted successfully",
        "rating_id": rating.id,
        "score": rating.score
    }


@router.get("/providers/{provider_id}/rating")
def get_provider_rating(
    provider_id: UUID,
    session: Session = Depends(get_session),
):
    # Get all ratings for the provider
    ratings = session.exec(
        select(Rating).where(Rating.target_id == provider_id)
    ).all()
    
    if not ratings:
        return {
            "provider_id": provider_id,
            "average_rating": 0.0,
            "total_ratings": 0,
            "ratings": []
        }
    
    avg_score = sum(r.score for r in ratings) / len(ratings)
    
    return {
        "provider_id": provider_id,
        "average_rating": round(avg_score, 2),
        "total_ratings": len(ratings),
        "ratings": [
            {
                "score": r.score,
                "comment": r.comment,
                "created_at": r.created_at
            }
            for r in sorted(ratings, key=lambda x: x.created_at, reverse=True)
        ]
    }