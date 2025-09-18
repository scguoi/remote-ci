"""User service unit tests."""

import pytest
from sqlalchemy.orm import Session

from app.core.schemas import UserCreate, UserUpdate
from app.core.services.user_service import UserService


class TestUserService:
    """User service test class."""

    def test_create_user_success(self, db_session: Session):
        """Test successful user creation."""
        service = UserService(db_session)
        user_create = UserCreate(
            username="testuser",
            email="test@example.com",
            full_name="Test User",
            password="password123",
        )

        user = service.create_user(user_create)

        assert user.username == "testuser"
        assert user.email == "test@example.com"
        assert user.full_name == "Test User"
        assert user.is_active is True
        assert user.version == 1

    def test_create_user_duplicate_username(self, db_session: Session):
        """Test creating user with duplicate username."""
        service = UserService(db_session)
        user_create = UserCreate(
            username="testuser", email="test1@example.com", password="password123"
        )

        # Create first user
        service.create_user(user_create)

        # Try to create user with same username
        user_create2 = UserCreate(
            username="testuser",  # Same username
            email="test2@example.com",
            password="password123",
        )

        with pytest.raises(ValueError, match="Username 'testuser' already exists"):
            service.create_user(user_create2)

    def test_create_user_duplicate_email(self, db_session: Session):
        """Test creating user with duplicate email."""
        service = UserService(db_session)
        user_create = UserCreate(
            username="testuser1", email="test@example.com", password="password123"
        )

        # Create first user
        service.create_user(user_create)

        # Try to create user with same email
        user_create2 = UserCreate(
            username="testuser2",
            email="test@example.com",  # Same email
            password="password123",
        )

        with pytest.raises(ValueError, match="Email 'test@example.com' already exists"):
            service.create_user(user_create2)

    def test_get_user_by_id(self, db_session: Session):
        """Test getting user by ID."""
        service = UserService(db_session)
        user_create = UserCreate(
            username="testuser", email="test@example.com", password="password123"
        )

        created_user = service.create_user(user_create)
        found_user = service.get_user_by_id(created_user.id)

        assert found_user is not None
        assert found_user.id == created_user.id
        assert found_user.username == "testuser"

    def test_get_user_by_username(self, db_session: Session):
        """Test getting user by username."""
        service = UserService(db_session)
        user_create = UserCreate(
            username="testuser", email="test@example.com", password="password123"
        )

        service.create_user(user_create)
        found_user = service.get_user_by_username("testuser")

        assert found_user is not None
        assert found_user.username == "testuser"

    def test_update_user_success(self, db_session: Session):
        """Test successful user update."""
        service = UserService(db_session)
        user_create = UserCreate(
            username="testuser", email="test@example.com", password="password123"
        )

        created_user = service.create_user(user_create)

        user_update = UserUpdate(
            email="newemail@example.com",
            full_name="Updated Name",
            version=created_user.version,
        )

        updated_user = service.update_user(created_user.id, user_update)

        assert updated_user is not None
        assert updated_user.email == "newemail@example.com"
        assert updated_user.full_name == "Updated Name"
        assert updated_user.version == created_user.version + 1

    def test_update_user_version_conflict(self, db_session: Session):
        """Test version conflict when updating user."""
        service = UserService(db_session)
        user_create = UserCreate(
            username="testuser", email="test@example.com", password="password123"
        )

        created_user = service.create_user(user_create)

        user_update = UserUpdate(
            email="newemail@example.com", version=99
        )  # Wrong version number

        with pytest.raises(ValueError, match="Version conflict"):
            service.update_user(created_user.id, user_update)

    def test_delete_user_success(self, db_session: Session):
        """Test successful user deletion."""
        service = UserService(db_session)
        user_create = UserCreate(
            username="testuser", email="test@example.com", password="password123"
        )

        created_user = service.create_user(user_create)
        success = service.delete_user(created_user.id, created_user.version)

        assert success is True

        # Verify user has been soft deleted
        deleted_user = service.get_user_by_id(created_user.id)
        assert deleted_user is None

    def test_list_users(self, db_session: Session):
        """Test user list query."""
        service = UserService(db_session)

        # Create multiple users
        for i in range(5):
            user_create = UserCreate(
                username=f"user{i}",
                email=f"user{i}@example.com",
                password="password123",
            )
            service.create_user(user_create)

        # Test paginated query
        result = service.list_users(page=0, size=3)

        assert result.total == 5
        assert result.page == 0
        assert result.size == 3
        assert len(result.users) == 3
