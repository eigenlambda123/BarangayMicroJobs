from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, status
from sqlmodel import Session, select
from passlib.context import CryptContext
from uuid import UUID

from database import get_session
from models import User 

from schemas.auth import RegisterRequest, LoginRequest, UpdateProfileRequest
from utils.auth_utils import verify_password, create_access_token, get_current_user
from utils.file_uploads import save_uploaded_image

router = APIRouter(prefix="/auth", tags=["Authentication"])
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def build_user_profile(user: User) -> dict:
    """Build user profile dictionary with stats"""
    return {
        "id": user.id,
        "full_name": user.full_name,
        "phone_number": user.phone_number,
        "profile_image": user.profile_image,
        "email": user.email,
        "location": user.location,
        "skills": user.skills or [],
        "role": user.role,
        "is_verified": user.is_verified,
        "rating": user.rating,
        "review_count": user.review_count,
        "jobs_done": user.jobs_done,
        "jobs_posted": user.jobs_posted,
        "total_earned": user.total_earned,
    }

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
    Get current authenticated user profile with stats
    """
    return build_user_profile(current_user)

@router.get("/users/{user_id}")
def get_user(user_id: UUID, session: Session = Depends(get_session)):
    """
    Get user profile by ID
    """
    user = session.get(User, user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    
    return build_user_profile(user)

@router.put("/profile")
def update_profile(
    profile_data: UpdateProfileRequest,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
):
    """
    Update current user profile (phone, email, location, skills)
    """
    # Fetch fresh user instance from DB
    user = session.get(User, current_user.id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )

    # Update fields only if provided
    if profile_data.phone is not None:
        # Check if phone is already taken by another user
        existing = session.exec(
            select(User).where(
                (User.phone_number == profile_data.phone)
                & (User.id != user.id)
            )
        ).first()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Phone number already in use",
            )
        user.phone_number = profile_data.phone

    if profile_data.email is not None:
        user.email = profile_data.email

    if profile_data.location is not None:
        user.location = profile_data.location

    if profile_data.skills is not None:
        user.skills = profile_data.skills

    # Save changes
    session.add(user)
    session.commit()
    session.refresh(user)

    return {
        "message": "Profile updated successfully",
        "user": build_user_profile(user),
    }


@router.put("/me/profile-image")
def update_profile_image(
    image: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
):
    user = session.get(User, current_user.id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    user.profile_image = save_uploaded_image(image, "profiles")
    session.add(user)
    session.commit()
    session.refresh(user)

    return {
        "message": "Profile image updated successfully",
        "user": build_user_profile(user),
    }