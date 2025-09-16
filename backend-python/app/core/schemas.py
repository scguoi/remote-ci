"""Pydantic data validation and serialization schemas."""

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UserBase(BaseModel):
    """User base schema."""

    username: str = Field(..., min_length=3, max_length=50, description="Username")
    email: EmailStr = Field(..., description="Email address")
    full_name: Optional[str] = Field(None, max_length=100, description="Full name")
    is_active: bool = Field(True, description="Is active")


class UserCreate(UserBase):
    """Create user schema."""

    password: str = Field(..., min_length=6, max_length=128, description="Password")


class UserUpdate(BaseModel):
    """Update user schema."""

    email: Optional[EmailStr] = Field(None, description="Email address")
    full_name: Optional[str] = Field(None, max_length=100, description="Full name")
    is_active: Optional[bool] = Field(None, description="Is active")
    version: int = Field(..., description="Current version number (optimistic lock)")


class UserInDB(UserBase):
    """Database user schema."""

    model_config = ConfigDict(from_attributes=True)

    id: int = Field(..., description="User ID")
    hashed_password: str = Field(..., description="Hashed password")
    created_at: datetime = Field(..., description="Created at")
    updated_at: datetime = Field(..., description="Updated at")
    created_by: str = Field(..., description="Created by")
    updated_by: str = Field(..., description="Updated by")
    version: int = Field(..., description="Version")
    deleted_at: Optional[datetime] = Field(None, description="Deleted at")


class UserResponse(UserBase):
    """User response schema."""

    model_config = ConfigDict(from_attributes=True)

    id: int = Field(..., description="User ID")
    created_at: datetime = Field(..., description="Created at")
    updated_at: datetime = Field(..., description="Updated at")
    version: int = Field(..., description="Version")


class UserListResponse(BaseModel):
    """User list response schema."""

    total: int = Field(..., description="Total count")
    page: int = Field(..., description="Page number")
    size: int = Field(..., description="Page size")
    users: list[UserResponse] = Field(..., description="User list")


class APIResponse(BaseModel):
    """Unified API response format."""

    success: bool = Field(..., description="Success status")
    message: str = Field(..., description="Response message")
    data: Optional[dict] = Field(default=None, description="Response data")
    error: Optional[str] = Field(default=None, description="Error information")
    timestamp: datetime = Field(
        default_factory=datetime.utcnow, description="Response timestamp"
    )


class HealthResponse(BaseModel):
    """Health check response."""

    status: str = Field(..., description="Service status")
    timestamp: datetime = Field(
        default_factory=datetime.utcnow, description="Check time"
    )
    version: str = Field("1.0.0", description="Service version")
