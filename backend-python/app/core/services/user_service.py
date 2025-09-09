"""用户业务逻辑服务层."""

from typing import Optional

from sqlalchemy.orm import Session

from ...db.dao.user_dao import UserDAO
from ..models import User
from ..schemas import UserCreate, UserListResponse, UserResponse, UserUpdate
from ..security import hash_password


class UserService:
    """用户业务逻辑服务."""

    def __init__(self, db: Session):
        self.db = db
        self.user_dao = UserDAO(db)

    def create_user(
        self, user_create: UserCreate, created_by: str = "system"
    ) -> UserResponse:
        """创建用户."""
        # 检查用户名和邮箱是否已存在
        if self.user_dao.check_username_exists(user_create.username):
            raise ValueError(f"用户名 '{user_create.username}' 已存在")

        if self.user_dao.check_email_exists(user_create.email):
            raise ValueError(f"邮箱 '{user_create.email}' 已存在")

        # 加密密码
        hashed_password = hash_password(user_create.password)

        # 创建用户对象（临时处理密码）
        user_data = user_create.model_copy()

        # 创建用户记录
        db_user = self.user_dao.create_user(user_data, created_by)

        # 更新加密密码（这里需要重新设置）
        db_user.hashed_password = hashed_password
        self.db.commit()

        return UserResponse.model_validate(db_user)

    def get_user_by_id(self, user_id: int) -> Optional[UserResponse]:
        """根据ID获取用户."""
        db_user = self.user_dao.get_user_by_id(user_id)
        if not db_user:
            return None
        return UserResponse.model_validate(db_user)

    def get_user_by_username(self, username: str) -> Optional[UserResponse]:
        """根据用户名获取用户."""
        db_user = self.user_dao.get_user_by_username(username)
        if not db_user:
            return None
        return UserResponse.model_validate(db_user)

    def check_username_exists(self, username: str) -> bool:
        """检查用户名是否存在."""
        return self.user_dao.check_username_exists(username)

    def check_email_exists(self, email: str) -> bool:
        """检查邮箱是否存在."""
        return self.user_dao.check_email_exists(email)

    def list_users(
        self,
        page: int = 0,
        size: int = 10,
        is_active: Optional[bool] = None,
        username: Optional[str] = None,
        email: Optional[str] = None,
    ) -> UserListResponse:
        """分页查询用户列表."""
        if size > 100:  # 限制每页最大数量
            size = 100

        users, total = self.user_dao.list_users(page, size, is_active, username, email)

        user_responses = [UserResponse.model_validate(user) for user in users]

        return UserListResponse(total=total, page=page, size=size, users=user_responses)

    def update_user(
        self, user_id: int, user_update: UserUpdate, updated_by: str = "system"
    ) -> Optional[UserResponse]:
        """更新用户."""
        # 检查邮箱唯一性（如果要更新邮箱）
        if user_update.email:
            existing_user = self.user_dao.get_user_by_email(user_update.email)
            if existing_user and existing_user.id != user_id:
                raise ValueError(f"邮箱 '{user_update.email}' 已被其他用户使用")

        db_user = self.user_dao.update_user(user_id, user_update, updated_by)
        if not db_user:
            return None

        return UserResponse.model_validate(db_user)

    def delete_user(
        self, user_id: int, version: int, deleted_by: str = "system"
    ) -> bool:
        """删除用户."""
        return self.user_dao.delete_user(user_id, version, deleted_by)

    def authenticate_user(self, username: str, password: str) -> Optional[User]:
        """用户身份验证."""
        from ..security import verify_password

        db_user = self.user_dao.get_user_by_username(username)
        if not db_user or not db_user.is_active:
            return None

        if not verify_password(password, db_user.hashed_password):
            return None

        return db_user
