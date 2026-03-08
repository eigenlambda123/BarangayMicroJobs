from pydantic import BaseModel

class JobCreateRequest(BaseModel):
    title: str
    description: str
    location: str
    salary: float