"""SQLAlchemy数据库模型定义."""

from datetime import datetime
from typing import Any

from sqlalchemy import Boolean, Column, DateTime, Integer, String
from sqlalchemy.orm import declarative_base

Base: Any = declarative_base()


class User(Base):
    """用户数据库模型."""

    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True, comment="用户ID")
    username = Column(
        String(50), unique=True, index=True, nullable=False, comment="用户名"
    )
    email = Column(String(255), unique=True, index=True, nullable=False, comment="邮箱")
    full_name = Column(String(100), nullable=True, comment="全名")
    hashed_password = Column(String(255), nullable=False, comment="加密密码")
    is_active = Column(Boolean, default=True, comment="是否激活")

    # 审计字段
    created_at = Column(DateTime, default=datetime.utcnow, comment="创建时间")
    updated_at = Column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, comment="更新时间"
    )
    created_by = Column(String(50), default="system", comment="创建者")
    updated_by = Column(String(50), default="system", comment="更新者")

    # 乐观锁版本控制
    version = Column(Integer, default=1, comment="版本号")

    # 软删除标记
    deleted_at = Column(DateTime, nullable=True, comment="删除时间")

    def __repr__(self) -> str:
        return f"<User(id={self.id}, username='{self.username}', email='{self.email}')>"
