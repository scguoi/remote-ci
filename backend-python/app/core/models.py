"""SQLAlchemy database model definitions."""

from datetime import datetime
from typing import Any

from sqlalchemy import Boolean, Column, DateTime, Integer, String
from sqlalchemy.orm import declarative_base

Base: Any = declarative_base()


class User(Base):
    """User database model."""

    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True, comment="User ID")
    username = Column(
        String(50), unique=True, index=True, nullable=False, comment="Username"
    )
    email = Column(
        String(255), unique=True, index=True, nullable=False, comment="Email"
    )
    full_name = Column(String(100), nullable=True, comment="Full name")
    hashed_password = Column(String(255), nullable=False, comment="Hashed password")
    is_active = Column(Boolean, default=True, comment="Is active")

    # Audit fields
    created_at = Column(DateTime, default=datetime.utcnow, comment="Created at")
    updated_at = Column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        comment="Updated at",
    )
    created_by = Column(String(50), default="system", comment="Created by")
    updated_by = Column(String(50), default="system", comment="Updated by")

    # Optimistic locking version control
    version = Column(Integer, default=1, comment="Version")

    # Soft delete marker
    deleted_at = Column(DateTime, nullable=True, comment="Deleted at")

    def __repr__(self) -> str:
        return f"<User(id={self.id}, username='{self.username}', email='{self.email}')>"
