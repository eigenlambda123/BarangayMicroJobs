from pydantic import BaseModel, field_validator
from typing import Optional
from ..utils.locations import is_valid_location

class JobCreateRequest(BaseModel):
    title: str
    description: str
    location: str
    salary: float
    image: Optional[str] = None

    @field_validator('location')
    @classmethod
    def validate_location(cls, v: str) -> str:
        """Validates that the location is a valid barangay in Lucena City"""
        if not is_valid_location(v):
            raise ValueError(f"Invalid location: {v}. Must be a valid barangay in Lucena City.")
        return v