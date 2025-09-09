"""用户数据访问对象（DAO）."""

from datetime import datetime
from typing import List, Optional, Tuple

from sqlalchemy import and_
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from ...core.models import User
from ...core.schemas import UserCreate, UserUpdate


class UserDAO:
    """用户数据访问对象."""

    def __init__(self, db: Session):
        self.db = db

    def create_user(self, user_create: UserCreate, created_by: str = "system") -> User:
        """创建用户."""
        db_user = User(
            username=user_create.username,
            email=user_create.email,
            full_name=user_create.full_name,
            hashed_password="",  # 这里应该传入已加密的密码
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
            raise ValueError("用户名或邮箱已存在")

    def get_user_by_id(self, user_id: int) -> Optional[User]:
        """根据ID获取用户."""
        return (
            self.db.query(User)
            .filter(and_(User.id == user_id, User.deleted_at.is_(None)))
            .first()
        )

    def get_user_by_username(self, username: str) -> Optional[User]:
        """根据用户名获取用户."""
        return (
            self.db.query(User)
            .filter(and_(User.username == username, User.deleted_at.is_(None)))
            .first()
        )

    def get_user_by_email(self, email: str) -> Optional[User]:
        """根据邮箱获取用户."""
        return (
            self.db.query(User)
            .filter(and_(User.email == email, User.deleted_at.is_(None)))
            .first()
        )

    def check_username_exists(self, username: str) -> bool:
        """检查用户名是否存在."""
        return (
            self.db.query(User)
            .filter(and_(User.username == username, User.deleted_at.is_(None)))
            .first()
            is not None
        )

    def check_email_exists(self, email: str) -> bool:
        """检查邮箱是否存在."""
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
        """分页查询用户列表."""
        query = self.db.query(User).filter(User.deleted_at.is_(None))

        # 应用过滤条件
        if is_active is not None:
            query = query.filter(User.is_active == is_active)

        if username:
            query = query.filter(User.username.contains(username))

        if email:
            query = query.filter(User.email.contains(email))

        # 获取总数
        total = query.count()

        # 分页查询
        users = query.offset(page * size).limit(size).all()

        return users, total

    def update_user(
        self, user_id: int, user_update: UserUpdate, updated_by: str = "system"
    ) -> Optional[User]:
        """更新用户（乐观锁）."""
        db_user = self.get_user_by_id(user_id)
        if not db_user:
            return None

        # 检查版本号（乐观锁）
        if db_user.version != user_update.version:
            raise ValueError(f"版本冲突：当前版本 {db_user.version}，请求版本 {user_update.version}")

        # 更新字段
        update_data = user_update.model_dump(exclude_unset=True, exclude={"version"})
        for field, value in update_data.items():
            setattr(db_user, field, value)

        # 更新审计字段
        db_user.updated_at = datetime.utcnow()
        db_user.updated_by = updated_by
        db_user.version += 1

        try:
            self.db.commit()
            self.db.refresh(db_user)
            return db_user
        except IntegrityError:
            self.db.rollback()
            raise ValueError("邮箱已存在")

    def delete_user(
        self, user_id: int, version: int, deleted_by: str = "system"
    ) -> bool:
        """软删除用户（乐观锁）."""
        db_user = self.get_user_by_id(user_id)
        if not db_user:
            return False

        # 检查版本号（乐观锁）
        if db_user.version != version:
            raise ValueError(f"版本冲突：当前版本 {db_user.version}，请求版本 {version}")

        # 软删除
        db_user.deleted_at = datetime.utcnow()
        db_user.updated_at = datetime.utcnow()
        db_user.updated_by = deleted_by
        db_user.version += 1

        self.db.commit()
        return True
