from pydantic import BaseModel
from typing import Optional, List

class RegisterRequest(BaseModel):
    full_name: str
    phone_number: str
    role: str = "resident"
    password: str

class LoginRequest(BaseModel):
    phone_number: str
    password: str

class UpdateProfileRequest(BaseModel):
    phone: Optional[str] = None
    email: Optional[str] = None
    location: Optional[str] = None
    skills: Optional[List[str]] = None