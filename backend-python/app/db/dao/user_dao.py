"""User Data Access Object (DAO)."""

from datetime import datetime
from typing import List, Optional, Tuple

from sqlalchemy import and_
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from ...core.models import User
from ...core.schemas import UserCreate, UserUpdate


class UserDAO:
    """User data access object."""

    def __init__(self, db: Session):
        self.db = db

    def create_user(self, user_create: UserCreate, created_by: str = "system") -> User:
        """Create user."""
        db_user = User(
            username=user_create.username,
            email=user_create.email,
            full_name=user_create.full_name,
            hashed_password="",  # Should pass in hashed password here
            is_active=user_create.is_active,
            created_by=created_by,
            updated_by=created_by,
        )

        try:
            self.db.add(db_user)
            self.db.commit()
            self.db.refresh(db_user)
            return db_user
        except IntegrityError:
            self.db.rollback()
            raise ValueError("Username or email already exists")

    def get_user_by_id(self, user_id: int) -> Optional[User]:
        """Get user by ID."""
        return (
            self.db.query(User)
            .filter(and_(User.id == user_id, User.deleted_at.is_(None)))
            .first()
        )

    def get_user_by_username(self, username: str) -> Optional[User]:
        """Get user by username."""
        return (
            self.db.query(User)
            .filter(and_(User.username == username, User.deleted_at.is_(None)))
            .first()
        )

    def get_user_by_email(self, email: str) -> Optional[User]:
        """Get user by email."""
        return (
            self.db.query(User)
            .filter(and_(User.email == email, User.deleted_at.is_(None)))
            .first()
        )

    def check_username_exists(self, username: str) -> bool:
        """Check if username exists."""
        return (
            self.db.query(User)
            .filter(and_(User.username == username, User.deleted_at.is_(None)))
            .first()
            is not None
        )

    def check_email_exists(self, email: str) -> bool:
        """Check if email exists."""
        return (
            self.db.query(User)
            .filter(and_(User.email == email, User.deleted_at.is_(None)))
            .first()
            is not None
        )

    def list_users(
        self,
        page: int = 0,
        size: int = 10,
        is_active: Optional[bool] = None,
        username: Optional[str] = None,
        email: Optional[str] = None,
    ) -> Tuple[List[User], int]:
        """Paginated user list query."""
        query = self.db.query(User).filter(User.deleted_at.is_(None))

        # Apply filter conditions
        if is_active is not None:
            query = query.filter(User.is_active == is_active)

        if username:
            query = query.filter(User.username.contains(username))

        if email:
            query = query.filter(User.email.contains(email))

        # Get total count
        total = query.count()

        # Paginated query
        users = query.offset(page * size).limit(size).all()

        return users, total

    def update_user(
        self, user_id: int, user_update: UserUpdate, updated_by: str = "system"
    ) -> Optional[User]:
        """Update user (optimistic lock)."""
        db_user = self.get_user_by_id(user_id)
        if not db_user:
            return None

        # Check version number (optimistic lock)
        if db_user.version != user_update.version:
            raise ValueError(
                f"Version conflict: current version {db_user.version}, requested version {user_update.version}"
            )

        # Update fields
        update_data = user_update.model_dump(exclude_unset=True, exclude={"version"})
        for field, value in update_data.items():
            setattr(db_user, field, value)

        # Update audit fields
        db_user.updated_at = datetime.utcnow()
        db_user.updated_by = updated_by
        db_user.version += 1

        try:
            self.db.commit()
            self.db.refresh(db_user)
            return db_user
        except IntegrityError:
            self.db.rollback()
            raise ValueError("Email already exists")

    def delete_user(
        self, user_id: int, version: int, deleted_by: str = "system"
    ) -> bool:
        """Soft delete user (optimistic lock)."""
        db_user = self.get_user_by_id(user_id)
        if not db_user:
            return False

        # Check version number (optimistic lock)
        if db_user.version != version:
            raise ValueError(
                f"Version conflict: current version {db_user.version}, requested version {version}"
            )

        # Soft delete
        db_user.deleted_at = datetime.utcnow()
        db_user.updated_at = datetime.utcnow()
        db_user.updated_by = deleted_by
        db_user.version += 1

        self.db.commit()
        return True
