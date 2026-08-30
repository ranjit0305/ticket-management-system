from pydantic import BaseModel


# ==================================================
# TICKET CREATE
# ==================================================

class TicketCreate(BaseModel):
    title: str
    description: str
    priority: str
    status: str

# ==================================================
# TICKET RESPONSE
# ==================================================

class TicketResponse(BaseModel):
    id: int
    title: str
    description: str
    priority: str
    status: str

    created_by: int
    created_by_username: str | None = None

    assigned_to: int | None = None
    assigned_username: str | None = None


# ==================================================
# USER CREATE
# ==================================================

class UserCreate(BaseModel):
    username: str
    password: str