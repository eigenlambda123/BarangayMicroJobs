from pydantic import BaseModel, Field
from typing import Optional

class RatingRequest(BaseModel):
    score: int = Field(ge=1, le=5, description="Rating score from 1 to 5")
    comment: Optional[str] = Field(None, max_length=500, description="Optional comment about the service")

class RatingResponse(BaseModel):
    id: str
    transaction_id: str
    score: int
    comment: Optional[str]
    created_at: str
