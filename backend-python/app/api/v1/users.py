"""User management API routes."""

from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Path, Query, status
from sqlalchemy.orm import Session

from ...core.schemas import APIResponse, UserCreate, UserUpdate
from ...core.services.user_service import UserService
from ...db.database import get_db

router = APIRouter(prefix="/users", tags=["User Management"])


def get_user_service(db: Session = Depends(get_db)) -> UserService:
    """Dependency injection function to get user service."""
    return UserService(db)


@router.post("/", response_model=APIResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    user_create: UserCreate, user_service: UserService = Depends(get_user_service)
):
    """Create user."""
    try:
        user = user_service.create_user(user_create)
        return APIResponse(
            success=True, message="User created successfully", data=user.model_dump()
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create user: {str(e)}",
        )


@router.get("/", response_model=APIResponse)
async def list_users(
    page: int = Query(0, ge=0, description="Page number"),
    size: int = Query(10, ge=1, le=100, description="Page size"),
    is_active: Optional[bool] = Query(None, description="Is active"),
    username: Optional[str] = Query(None, description="Username filter"),
    email: Optional[str] = Query(None, description="Email filter"),
    user_service: UserService = Depends(get_user_service),
):
    """Paginated user list query."""
    try:
        user_list = user_service.list_users(page, size, is_active, username, email)
        return APIResponse(
            success=True,
            message="User list retrieved successfully",
            data=user_list.model_dump(),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve user list: {str(e)}",
        )


@router.put("/{user_id}", response_model=APIResponse)
async def update_user(
    user_update: UserUpdate,
    user_id: int = Path(..., description="User ID"),
    user_service: UserService = Depends(get_user_service),
):
    """Update user."""
    try:
        user = user_service.update_user(user_id, user_update)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User ID {user_id} does not exist",
            )

        return APIResponse(
            success=True, message="User updated successfully", data=user.model_dump()
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update user: {str(e)}",
        )


@router.delete("/{user_id}", response_model=APIResponse)
async def delete_user(
    user_id: int = Path(..., description="User ID"),
    version: int = Query(..., description="Current version number (optimistic lock)"),
    user_service: UserService = Depends(get_user_service),
):
    """Delete user (soft delete)."""
    try:
        success = user_service.delete_user(user_id, version)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User ID {user_id} does not exist",
            )

        return APIResponse(
            success=True, message="User deleted successfully", data={"user_id": user_id}
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete user: {str(e)}",
        )


@router.get("/check-username/{username}", response_model=APIResponse)
async def check_username_exists(
    username: str = Path(..., description="Username"),
    user_service: UserService = Depends(get_user_service),
):
    """Check if username exists."""
    exists = user_service.check_username_exists(username)
    return APIResponse(
        success=True,
        message="Check completed",
        data={"username": username, "exists": exists},
    )


@router.get("/check-email", response_model=APIResponse)
async def check_email_exists(
    email: str = Query(..., description="Email address"),
    user_service: UserService = Depends(get_user_service),
):
    """Check if email exists."""
    exists = user_service.check_email_exists(email)
    return APIResponse(
        success=True, message="Check completed", data={"email": email, "exists": exists}
    )


@router.get("/username/{username}", response_model=APIResponse)
async def get_user_by_username(
    username: str = Path(..., description="Username"),
    user_service: UserService = Depends(get_user_service),
):
    """Get user by username."""
    user = user_service.get_user_by_username(username)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Username '{username}' does not exist",
        )

    return APIResponse(
        success=True, message="User retrieved successfully", data=user.model_dump()
    )


@router.get("/{user_id}", response_model=APIResponse)
async def get_user_by_id(
    user_id: int = Path(..., description="User ID"),
    user_service: UserService = Depends(get_user_service),
):
    """Get user by ID."""
    user = user_service.get_user_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User ID {user_id} does not exist",
        )

    return APIResponse(
        success=True, message="User retrieved successfully", data=user.model_dump()
    )
