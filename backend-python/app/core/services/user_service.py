"""User business logic service layer."""

from typing import Optional

from sqlalchemy.orm import Session

from ...db.dao.user_dao import UserDAO
from ..models import User
from ..schemas import UserCreate, UserListResponse, UserResponse, UserUpdate
from ..security import hash_password


class UserService:
    """User business logic service."""

    def __init__(self, db: Session):
        self.db = db
        self.user_dao = UserDAO(db)

    def create_user(
        self, user_create: UserCreate, created_by: str = "system"
    ) -> UserResponse:
        """Create user."""
        # Check if username and email already exist
        if self.user_dao.check_username_exists(user_create.username):
            raise ValueError(f"Username '{user_create.username}' already exists")

        if self.user_dao.check_email_exists(user_create.email):
            raise ValueError(f"Email '{user_create.email}' already exists")

        # Encrypt password
        hashed_password = hash_password(user_create.password)

        # Create user object (temporary password handling)
        user_data = user_create.model_copy()

        # Create user record
        db_user = self.user_dao.create_user(user_data, created_by)

        # Update hashed password (needs to be reset here)
        db_user.hashed_password = hashed_password
        self.db.commit()

        return UserResponse.model_validate(db_user)

    def get_user_by_id(self, user_id: int) -> Optional[UserResponse]:
        """Get user by ID."""
        db_user = self.user_dao.get_user_by_id(user_id)
        if not db_user:
            return None
        return UserResponse.model_validate(db_user)

    def get_user_by_username(self, username: str) -> Optional[UserResponse]:
        """Get user by username."""
        db_user = self.user_dao.get_user_by_username(username)
        if not db_user:
            return None
        return UserResponse.model_validate(db_user)

    def check_username_exists(self, username: str) -> bool:
        """Check if username exists."""
        return self.user_dao.check_username_exists(username)

    def check_email_exists(self, email: str) -> bool:
        """Check if email exists."""
        return self.user_dao.check_email_exists(email)

    def list_users(
        self,
        page: int = 0,
        size: int = 10,
        is_active: Optional[bool] = None,
        username: Optional[str] = None,
        email: Optional[str] = None,
    ) -> UserListResponse:
        """Paginated user list query."""
        if size > 100:  # Limit maximum number per page
            size = 100

        users, total = self.user_dao.list_users(page, size, is_active, username, email)

        user_responses = [UserResponse.model_validate(user) for user in users]

        return UserListResponse(total=total, page=page, size=size, users=user_responses)

    def update_user(
        self, user_id: int, user_update: UserUpdate, updated_by: str = "system"
    ) -> Optional[UserResponse]:
        """Update user."""
        # Check email uniqueness (if email is to be updated)
        if user_update.email:
            existing_user = self.user_dao.get_user_by_email(user_update.email)
            if existing_user and existing_user.id != user_id:
                raise ValueError(
                    f"Email '{user_update.email}' is already used by another user"
                )

        db_user = self.user_dao.update_user(user_id, user_update, updated_by)
        if not db_user:
            return None

        return UserResponse.model_validate(db_user)

    def delete_user(
        self, user_id: int, version: int, deleted_by: str = "system"
    ) -> bool:
        """Delete user."""
        return self.user_dao.delete_user(user_id, version, deleted_by)

    def authenticate_user(self, username: str, password: str) -> Optional[User]:
        """User authentication."""
        from ..security import verify_password

        db_user = self.user_dao.get_user_by_username(username)
        if not db_user or not db_user.is_active:
            return None

        if not verify_password(password, db_user.hashed_password):
            return None

        return db_user
