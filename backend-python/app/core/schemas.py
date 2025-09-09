"""Pydantic数据验证和序列化模式."""

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UserBase(BaseModel):
    """用户基础模式."""

    username: str = Field(..., min_length=3, max_length=50, description="用户名")
    email: EmailStr = Field(..., description="邮箱地址")
    full_name: Optional[str] = Field(None, max_length=100, description="全名")
    is_active: bool = Field(True, description="是否激活")


class UserCreate(UserBase):
    """创建用户模式."""

    password: str = Field(..., min_length=6, max_length=128, description="密码")


class UserUpdate(BaseModel):
    """更新用户模式."""

    email: Optional[EmailStr] = Field(None, description="邮箱地址")
    full_name: Optional[str] = Field(None, max_length=100, description="全名")
    is_active: Optional[bool] = Field(None, description="是否激活")
    version: int = Field(..., description="当前版本号（乐观锁）")


class UserInDB(UserBase):
    """数据库用户模式."""

    model_config = ConfigDict(from_attributes=True)

    id: int = Field(..., description="用户ID")
    hashed_password: str = Field(..., description="加密密码")
    created_at: datetime = Field(..., description="创建时间")
    updated_at: datetime = Field(..., description="更新时间")
    created_by: str = Field(..., description="创建者")
    updated_by: str = Field(..., description="更新者")
    version: int = Field(..., description="版本号")
    deleted_at: Optional[datetime] = Field(None, description="删除时间")


class UserResponse(UserBase):
    """用户响应模式."""

    model_config = ConfigDict(from_attributes=True)

    id: int = Field(..., description="用户ID")
    created_at: datetime = Field(..., description="创建时间")
    updated_at: datetime = Field(..., description="更新时间")
    version: int = Field(..., description="版本号")


class UserListResponse(BaseModel):
    """用户列表响应模式."""

    total: int = Field(..., description="总数")
    page: int = Field(..., description="页码")
    size: int = Field(..., description="每页大小")
    users: list[UserResponse] = Field(..., description="用户列表")


class APIResponse(BaseModel):
    """统一API响应格式."""

    success: bool = Field(..., description="是否成功")
    message: str = Field(..., description="响应消息")
    data: Optional[dict] = Field(default=None, description="响应数据")
    error: Optional[str] = Field(default=None, description="错误信息")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="响应时间戳")


class HealthResponse(BaseModel):
    """健康检查响应."""

    status: str = Field(..., description="服务状态")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="检查时间")
    version: str = Field("1.0.0", description="服务版本")
