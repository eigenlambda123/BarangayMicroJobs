from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from passlib.context import CryptContext

from database import get_session
from models import User 

from schemas.auth import RegisterRequest, LoginRequest
from utils.auth_utils import verify_password, create_access_token, get_current_user

router = APIRouter(prefix="/auth", tags=["Authentication"])
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

@router.post("/login")
def login_user(login_data: LoginRequest, session: Session = Depends(get_session)):
    # Find the user
    statement = select(User).where(User.phone_number == login_data.phone_number)
    user = session.exec(statement).first()

    # Validate user and password
    if not user or not verify_password(login_data.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid phone number or password")

    # Create access token
    access_token = create_access_token(data={"sub": str(user.id), "role": user.role})

    return {"access_token": access_token,
            "token_type": "bearer",
            "user": {
                "id": user.id,
                "full_name": user.full_name,
                "is_verified": user.is_verified,
            }       
        }    

@router.get("/me")
def get_me(current_user: User = Depends(get_current_user)):
    """
    Get current authenticated user profile
    """
    return {
        "id": current_user.id,
        "full_name": current_user.full_name,
        "phone_number": current_user.phone_number,
        "role": current_user.role,
        "is_verified": current_user.is_verified
    }