from pydantic import BaseModel
from typing import Optional

class JobCreateRequest(BaseModel):
    title: str
    description: str
    location: str
    salary: float
    image: Optional[str] = None