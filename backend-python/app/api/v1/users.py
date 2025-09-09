"""用户管理API路由."""

from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Path, Query, status
from sqlalchemy.orm import Session

from ...core.schemas import APIResponse, UserCreate, UserUpdate
from ...core.services.user_service import UserService
from ...db.database import get_db

router = APIRouter(prefix="/users", tags=["用户管理"])


def get_user_service(db: Session = Depends(get_db)) -> UserService:
    """获取用户服务的依赖注入函数."""
    return UserService(db)


@router.post("/", response_model=APIResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    user_create: UserCreate, user_service: UserService = Depends(get_user_service)
):
    """创建用户."""
    try:
        user = user_service.create_user(user_create)
        return APIResponse(success=True, message="用户创建成功", data=user.model_dump())
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"创建用户失败: {str(e)}",
        )


@router.get("/", response_model=APIResponse)
async def list_users(
    page: int = Query(0, ge=0, description="页码"),
    size: int = Query(10, ge=1, le=100, description="每页大小"),
    is_active: Optional[bool] = Query(None, description="是否激活"),
    username: Optional[str] = Query(None, description="用户名过滤"),
    email: Optional[str] = Query(None, description="邮箱过滤"),
    user_service: UserService = Depends(get_user_service),
):
    """分页查询用户列表."""
    try:
        user_list = user_service.list_users(page, size, is_active, username, email)
        return APIResponse(
            success=True, message="获取用户列表成功", data=user_list.model_dump()
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取用户列表失败: {str(e)}",
        )


@router.put("/{user_id}", response_model=APIResponse)
async def update_user(
    user_update: UserUpdate,
    user_id: int = Path(..., description="用户ID"),
    user_service: UserService = Depends(get_user_service),
):
    """更新用户."""
    try:
        user = user_service.update_user(user_id, user_update)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"用户 ID {user_id} 不存在",
            )

        return APIResponse(success=True, message="用户更新成功", data=user.model_dump())
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"更新用户失败: {str(e)}",
        )


@router.delete("/{user_id}", response_model=APIResponse)
async def delete_user(
    user_id: int = Path(..., description="用户ID"),
    version: int = Query(..., description="当前版本号（乐观锁）"),
    user_service: UserService = Depends(get_user_service),
):
    """删除用户（软删除）."""
    try:
        success = user_service.delete_user(user_id, version)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"用户 ID {user_id} 不存在",
            )

        return APIResponse(success=True, message="用户删除成功", data={"user_id": user_id})
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"删除用户失败: {str(e)}",
        )


@router.get("/check-username/{username}", response_model=APIResponse)
async def check_username_exists(
    username: str = Path(..., description="用户名"),
    user_service: UserService = Depends(get_user_service),
):
    """检查用户名是否存在."""
    exists = user_service.check_username_exists(username)
    return APIResponse(
        success=True, message="检查完成", data={"username": username, "exists": exists}
    )


@router.get("/check-email", response_model=APIResponse)
async def check_email_exists(
    email: str = Query(..., description="邮箱地址"),
    user_service: UserService = Depends(get_user_service),
):
    """检查邮箱是否存在."""
    exists = user_service.check_email_exists(email)
    return APIResponse(
        success=True, message="检查完成", data={"email": email, "exists": exists}
    )


@router.get("/username/{username}", response_model=APIResponse)
async def get_user_by_username(
    username: str = Path(..., description="用户名"),
    user_service: UserService = Depends(get_user_service),
):
    """根据用户名获取用户."""
    user = user_service.get_user_by_username(username)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail=f"用户名 '{username}' 不存在"
        )

    return APIResponse(success=True, message="获取用户成功", data=user.model_dump())


@router.get("/{user_id}", response_model=APIResponse)
async def get_user_by_id(
    user_id: int = Path(..., description="用户ID"),
    user_service: UserService = Depends(get_user_service),
):
    """根据ID获取用户."""
    user = user_service.get_user_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail=f"用户 ID {user_id} 不存在"
        )

    return APIResponse(success=True, message="获取用户成功", data=user.model_dump())
