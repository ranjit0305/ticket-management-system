from sqlalchemy import Column, String, Text, Integer, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy import Sequence
from database import Base


class Ticket(Base):
    __tablename__ = "tickets"

    id = Column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )

    title = Column(String, nullable=False)

    description = Column(
        String,
        nullable=False,
    )

    priority = Column(
        String,
        nullable=False,
    )

    status = Column(
        String,
        nullable=False,
    )

    assigned_to = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=True,
    )

    created_by = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False,
    )

    creator = relationship(
        "User",
        foreign_keys=[created_by],
    )

    assignee = relationship(
        "User",
        foreign_keys=[assigned_to],
    )

class User(Base):
    __tablename__ = "users"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
    )

    username = Column(
        String(50),
        unique=True,
        nullable=False,
    )

    password = Column(
        String(255),
        nullable=False,
    )

    role = Column(
        String(20),
        default="user",
        nullable=False,
    )

    full_name = Column(String(100), nullable=True)
    email = Column(String(255), nullable=True)
    department = Column(String(100), nullable=True)

    # -----------------------------------------------
    # TICKETS ASSIGNED TO THIS USER
    # -----------------------------------------------

    assigned_tickets = relationship(
        "Ticket",
        foreign_keys="Ticket.assigned_to",
        back_populates="assignee",
    )

    # -----------------------------------------------
    # TICKETS CREATED BY THIS USER
    # -----------------------------------------------

    created_tickets = relationship(
        "Ticket",
        foreign_keys="Ticket.created_by",
        back_populates="creator",
    )
