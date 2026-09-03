from fastapi import FastAPI, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from database import Base, engine, SessionLocal, get_db, ensure_user_profile_columns
from database import get_db
from models import User, Ticket
from schemas import (
    TicketCreate,
    TicketResponse,
    UserCreate,
)
from auth import hash_password, verify_password
from jwt_utils import create_access_token
from dependencies import get_current_user, require_admin

from redis_client import redis_client
import json

# --------------------------------------------------
# DATABASE
# --------------------------------------------------

Base.metadata.create_all(bind=engine)
ensure_user_profile_columns()


# --------------------------------------------------
# FASTAPI APP
# --------------------------------------------------

app = FastAPI()


# --------------------------------------------------
# GET USER BY USERNAME
# --------------------------------------------------

def get_user_by_username(username: str):
    db = SessionLocal()

    try:
        return (
            db.query(User)
            .filter(User.username == username)
            .first()
        )
    finally:
        db.close()


# --------------------------------------------------
# HOME
# --------------------------------------------------

@app.get("/")
def home():
    return {
        "message": "Ticket Management API is running"
    }


# --------------------------------------------------
# GET ALL TICKETS
# --------------------------------------------------

@app.get("/tickets")
def get_tickets(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    cache_key = f"tickets:user:{current_user.id}"

    # -----------------------------------------------
    # CHECK REDIS CACHE
    # -----------------------------------------------

    cached_tickets = redis_client.get(cache_key)

    if cached_tickets:
        return json.loads(cached_tickets)

    # -----------------------------------------------
    # GET FROM DATABASE
    # -----------------------------------------------

    if current_user.role == "admin":
        tickets = db.query(Ticket).all()
    else:
        tickets = (
            db.query(Ticket)
            .filter(Ticket.assigned_to == current_user.id)
            .all()
        )

    result = [
        {
            "id": ticket.id,
            "title": ticket.title,
            "description": ticket.description,
            "priority": ticket.priority,
            "status": ticket.status,
            "created_by": ticket.created_by,
            "created_by_username": (
                ticket.creator.username
                if ticket.creator
                else None
            ),
            "assigned_to": ticket.assigned_to,
            "assigned_username": (
                ticket.assignee.username
                if ticket.assignee
                else None
            ),
        }
        for ticket in tickets
    ]

    # -----------------------------------------------
    # STORE IN REDIS
    # -----------------------------------------------

    redis_client.setex(
        cache_key,
        60,
        json.dumps(result),
    )

    return result
# --------------------------------------------------
# CREATE TICKET
# --------------------------------------------------
@app.post(
    "/tickets",
    response_model=TicketResponse,
)
def create_ticket(
    ticket: TicketCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    new_ticket = Ticket(
        title=ticket.title,
        description=ticket.description,
        priority=ticket.priority,
        status=ticket.status,
        created_by=current_user.id,
        assigned_to=None,
    )

    db.add(new_ticket)

    db.commit()

    db.refresh(new_ticket)

    redis_client.delete(
    f"tickets:user:{current_user.id}"
)

    return {
        "id": new_ticket.id,
        "title": new_ticket.title,
        "description": new_ticket.description,
        "priority": new_ticket.priority,
        "status": new_ticket.status,

        "created_by": new_ticket.created_by,

        "created_by_username": (
            new_ticket.creator.username
            if new_ticket.creator
            else None
        ),

        "assigned_to": new_ticket.assigned_to,

        "assigned_username": (
            new_ticket.assignee.username
            if new_ticket.assignee
            else None
        ),
    }
# --------------------------------------------------
# UPDATE TICKET
# --------------------------------------------------

@app.put(
    "/tickets/{ticket_id}",
    response_model=TicketResponse,
)
def update_ticket(
    ticket_id: int,
    ticket_data: TicketCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    ticket = (
        db.query(Ticket)
        .filter(Ticket.id == ticket_id)
        .first()
    )

    if ticket is None:
        raise HTTPException(
            status_code=404,
            detail="Ticket not found",
        )

    # -----------------------------------------------
    # PERMISSION CHECK
    # -----------------------------------------------

    if (
        current_user.role != "admin"
        and ticket.assigned_to != current_user.id
    ):
        raise HTTPException(
            status_code=403,
            detail="You can only edit tickets assigned to you",
        )

    # -----------------------------------------------
    # UPDATE ALLOWED FIELDS
    # -----------------------------------------------

    ticket.title = ticket_data.title
    ticket.description = ticket_data.description
    ticket.priority = ticket_data.priority
    ticket.status = ticket_data.status


    db.commit()

    db.refresh(ticket)

    keys = redis_client.keys("tickets:user:*")

    if keys:
        redis_client.delete(*keys)

    return {
        "id": ticket.id,
        "title": ticket.title,
        "description": ticket.description,
        "priority": ticket.priority,
        "status": ticket.status,

        "created_by": ticket.created_by,
        "created_by_username": (
            ticket.creator.username
            if ticket.creator
            else None
        ),

        "assigned_to": ticket.assigned_to,
        "assigned_username": (
            ticket.assignee.username
            if ticket.assignee
            else None
        ),
    }


# --------------------------------------------------
# DELETE TICKET - ADMIN ONLY
# --------------------------------------------------

@app.delete("/tickets/{ticket_id}")
def delete_ticket(
    ticket_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    ticket = (
        db.query(Ticket)
        .filter(Ticket.id == ticket_id)
        .first()
    )

    if ticket is None:
        raise HTTPException(
            status_code=404,
            detail="Ticket not found"
        )

    db.delete(ticket)
    db.commit()

    keys = redis_client.keys("tickets:user:*")

    if keys:
        redis_client.delete(*keys)

    return {
        "message": "Ticket deleted successfully"
    }


# --------------------------------------------------
# REGISTER
# --------------------------------------------------

@app.post("/register")
def register(
    user: UserCreate,
    db: Session = Depends(get_db)
):
    existing_user = (
        db.query(User)
        .filter(User.username == user.username)
        .first()
    )

    if existing_user:
        raise HTTPException(
            status_code=400,
            detail="Username already exists"
        )

    hashed_password = hash_password(
        user.password
    )

    new_user = User(
        username=user.username,
        password=hashed_password,
        role="user",
        full_name=user.full_name,
        email=user.email,
        department=user.department,
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {
        "message": "User registered successfully"
    }

# --------------------------------------------------
# CREATE USER - ADMIN ONLY
# --------------------------------------------------

@app.post("/users")
def create_user(
    user: UserCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    # Check whether username already exists
    existing_user = (
        db.query(User)
        .filter(User.username == user.username)
        .first()
    )

    if existing_user:
        raise HTTPException(
            status_code=400,
            detail="Username already exists",
        )

    # Hash password
    hashed_password = hash_password(user.password)

    # Create user
    new_user = User(
        username=user.username,
        password=hashed_password,
        role="user",
        full_name=user.full_name,
        email=user.email,
        department=user.department,
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {
        "message": "User created successfully",
        "id": new_user.id,
        "username": new_user.username,
        "role": new_user.role,
        "full_name": new_user.full_name,
        "email": new_user.email,
        "department": new_user.department,
    }

@app.get("/users")
def get_users(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    users = db.query(User).all()

    return [
        {
            "id": user.id,
            "username": user.username,
            "role": user.role,
            "full_name": user.full_name,
            "email": user.email,
            "department": user.department,
        }
        for user in users
    ]
# --------------------------------------------------
# LOGIN
# --------------------------------------------------

@app.post("/login")
def login(
    form_data: OAuth2PasswordRequestForm = Depends()
):
    user = get_user_by_username(
        form_data.username
    )

    if not user:
        raise HTTPException(
            status_code=401,
            detail="Invalid username or password"
        )

    password_correct = verify_password(
        form_data.password,
        user.password
    )

    if not password_correct:
        raise HTTPException(
            status_code=401,
            detail="Invalid username or password"
        )

    # IMPORTANT:
    # create_access_token expects `data`
    access_token = create_access_token(
        data={
            "sub": user.username,
            "role": user.role,
        }
    )

    return {
    "access_token": access_token,
    "token_type": "bearer",
    "role": user.role,
    }

@app.put("/tickets/{ticket_id}/assign/{user_id}")
def assign_ticket(
    ticket_id: int,
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    # -----------------------------------------------
    # FIND TICKET
    # -----------------------------------------------

    ticket = (
        db.query(Ticket)
        .filter(Ticket.id == ticket_id)
        .first()
    )

    if ticket is None:
        raise HTTPException(
            status_code=404,
            detail="Ticket not found",
        )

    # -----------------------------------------------
    # FIND USER
    # -----------------------------------------------

    user = (
        db.query(User)
        .filter(User.id == user_id)
        .first()
    )

    if user is None:
        raise HTTPException(
            status_code=404,
            detail="User not found",
        )

    # -----------------------------------------------
    # ASSIGN TICKET
    # -----------------------------------------------

    ticket.assigned_to = user.id

    db.commit()
    db.refresh(ticket)

    keys = redis_client.keys("tickets:user:*")

    if keys:
        redis_client.delete(*keys)

    return {
        "message": "Ticket assigned successfully",
        "ticket_id": ticket.id,
        "assigned_to": user.id,
        "username": user.username,
    }
