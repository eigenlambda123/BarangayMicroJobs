from pydantic import BaseModel

class RegisterRequest(BaseModel):
    full_name: str
    phone_number: str
    role: str = "resident"
    password: str