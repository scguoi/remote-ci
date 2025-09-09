"""用户服务单元测试."""

import pytest
from sqlalchemy.orm import Session

from app.core.schemas import UserCreate, UserUpdate
from app.core.services.user_service import UserService


class TestUserService:
    """用户服务测试类."""

    def test_create_user_success(self, db_session: Session):
        """测试成功创建用户."""
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
        """测试创建重复用户名的用户."""
        service = UserService(db_session)
        user_create = UserCreate(
            username="testuser", email="test1@example.com", password="password123"
        )

        # 创建第一个用户
        service.create_user(user_create)

        # 尝试创建相同用户名的用户
        user_create2 = UserCreate(
            username="testuser",  # 相同用户名
            email="test2@example.com",
            password="password123",
        )

        with pytest.raises(ValueError, match="用户名 'testuser' 已存在"):
            service.create_user(user_create2)

    def test_create_user_duplicate_email(self, db_session: Session):
        """测试创建重复邮箱的用户."""
        service = UserService(db_session)
        user_create = UserCreate(
            username="testuser1", email="test@example.com", password="password123"
        )

        # 创建第一个用户
        service.create_user(user_create)

        # 尝试创建相同邮箱的用户
        user_create2 = UserCreate(
            username="testuser2",
            email="test@example.com",  # 相同邮箱
            password="password123",
        )

        with pytest.raises(ValueError, match="邮箱 'test@example.com' 已存在"):
            service.create_user(user_create2)

    def test_get_user_by_id(self, db_session: Session):
        """测试根据ID获取用户."""
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
        """测试根据用户名获取用户."""
        service = UserService(db_session)
        user_create = UserCreate(
            username="testuser", email="test@example.com", password="password123"
        )

        service.create_user(user_create)
        found_user = service.get_user_by_username("testuser")

        assert found_user is not None
        assert found_user.username == "testuser"

    def test_update_user_success(self, db_session: Session):
        """测试成功更新用户."""
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
        """测试更新用户时的版本冲突."""
        service = UserService(db_session)
        user_create = UserCreate(
            username="testuser", email="test@example.com", password="password123"
        )

        created_user = service.create_user(user_create)

        user_update = UserUpdate(email="newemail@example.com", version=99)  # 错误的版本号

        with pytest.raises(ValueError, match="版本冲突"):
            service.update_user(created_user.id, user_update)

    def test_delete_user_success(self, db_session: Session):
        """测试成功删除用户."""
        service = UserService(db_session)
        user_create = UserCreate(
            username="testuser", email="test@example.com", password="password123"
        )

        created_user = service.create_user(user_create)
        success = service.delete_user(created_user.id, created_user.version)

        assert success is True

        # 验证用户已被软删除
        deleted_user = service.get_user_by_id(created_user.id)
        assert deleted_user is None

    def test_list_users(self, db_session: Session):
        """测试用户列表查询."""
        service = UserService(db_session)

        # 创建多个用户
        for i in range(5):
            user_create = UserCreate(
                username=f"user{i}",
                email=f"user{i}@example.com",
                password="password123",
            )
            service.create_user(user_create)

        # 测试分页查询
        result = service.list_users(page=0, size=3)

        assert result.total == 5
        assert result.page == 0
        assert result.size == 3
        assert len(result.users) == 3
