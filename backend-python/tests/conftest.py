"""测试配置和公共fixture."""

import os

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.api.v1 import users
from app.core.config import settings
from app.core.models import Base
from app.core.schemas import APIResponse, HealthResponse
from app.db.database import get_db

# 设置测试环境变量
os.environ["DATABASE_URL"] = "sqlite:///./test.db"

# 使用内存SQLite数据库进行测试
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)

TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    """测试数据库会话依赖."""
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


# 创建测试专用的FastAPI应用（不使用lifespan）
def create_test_app():
    """创建测试用的FastAPI应用."""
    test_app = FastAPI(
        title=settings.project_name,
        description=settings.description,
        version=settings.version,
        # 不使用lifespan避免数据库连接问题
    )

    # 健康检查端点
    @test_app.get("/healthz", response_model=HealthResponse, tags=["健康检查"])
    async def health_check():
        """服务健康检查."""
        from datetime import datetime

        return HealthResponse(
            status="healthy", timestamp=datetime.utcnow(), version=settings.version
        )

    @test_app.get("/", response_model=APIResponse, tags=["根路径"])
    async def root():
        """根路径欢迎信息."""
        from datetime import datetime

        return APIResponse(
            success=True,
            message=f"欢迎使用 {settings.project_name}",
            data={
                "version": settings.version,
                "docs_url": "/docs",
                "health_check": "/healthz",
            },
        )

    # 注册API路由
    test_app.include_router(users.router, prefix="/api/v1", tags=["API v1"])

    return test_app


@pytest.fixture(scope="function")
def db_session():
    """创建测试数据库会话."""
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def client(db_session):
    """创建测试客户端."""
    test_app = create_test_app()
    test_app.dependency_overrides[get_db] = override_get_db

    with TestClient(test_app) as test_client:
        yield test_client

    test_app.dependency_overrides.clear()
