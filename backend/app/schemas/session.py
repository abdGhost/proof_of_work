from datetime import datetime

from pydantic import BaseModel


class CreateSessionRequest(BaseModel):
    category: str
    task_name: str
    duration: int
    notes: str = ""


class SessionResponse(BaseModel):
    id: int
    user_id: int
    category: str
    task_name: str
    duration: int
    notes: str
    created_at: datetime

    class Config:
        from_attributes = True
