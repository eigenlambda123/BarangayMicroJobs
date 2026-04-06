from pydantic import BaseModel
from uuid import UUID

class ApplicantsInfo(BaseModel):
    transaction_id: UUID
    id: UUID
    name: str
    rating: float
    review_count: int
    phone_number: str
    status: str