from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from passlib.context import CryptContext

from database import get_session
from models import User 

from schemas.auth import RegisterRequest

router = APIRouter()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

@router.post("/register")
def register_user(user_data: RegisterRequest, session: Session = Depends(get_session)):
    # Check if the user already exist
    statement = select(User).where(User.phone_number == user_data.phone_number)
    existing_user = session.exec(statement).first()
    if existing_user:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Phone number already registered")
    
    # Hash the password
    hashed_password = pwd_context.hash(user_data.password)

    # Create new user
    new_user = User(
        full_name=user_data.full_name,
        phone_number=user_data.phone_number,
        role=user_data.role,
        hashed_password=hashed_password
    )

    # Save to DB
    session.add(new_user)
    session.commit()
    session.refresh(new_user)

    return {"message": "User created successfully", "user_id": new_user.id}