from pydantic import BaseModel
from uuid import UUID

class ApplicantsInfo(BaseModel):
    id: UUID
    name: str
    rating: int
    phone_number: str