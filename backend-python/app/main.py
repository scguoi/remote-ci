"""FastAPI应用程序主入口."""

from contextlib import asynccontextmanager
from datetime import datetime

from fastapi import FastAPI, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .api.v1 import users
from .core.config import settings
from .core.models import Base
from .core.schemas import APIResponse, HealthResponse
from .db.database import engine


@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用程序生命周期管理."""
    # 启动时：创建数据库表（测试时会被覆盖）
    try:
        Base.metadata.create_all(bind=engine)
        print(f"🚀 {settings.project_name} 启动成功")
        print(f"📖 API文档: http://{settings.host}:{settings.port}/docs")
    except Exception as e:
        # 测试时可能会有连接错误，这是正常的
        if "test" not in settings.database_url.lower():
            print(f"⚠️ 数据库连接警告: {e}")
        pass
    yield
    # 关闭时的清理工作
    print(f"🛑 {settings.project_name} 已停止")


# 创建FastAPI应用实例
app = FastAPI(
    title=settings.project_name,
    description=settings.description,
    version=settings.version,
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

# 添加CORS中间件
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """全局异常处理."""
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content=APIResponse(
            success=False,
            message="服务器内部错误",
            error=str(exc) if not settings.is_production else "Internal Server Error",
        ).model_dump(),
    )


# 健康检查端点
@app.get("/healthz", response_model=HealthResponse, tags=["健康检查"])
async def health_check():
    """服务健康检查."""
    return HealthResponse(
        status="healthy", timestamp=datetime.utcnow(), version=settings.version
    )


@app.get("/", response_model=APIResponse, tags=["根路径"])
async def root():
    """根路径欢迎信息."""
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
app.include_router(users.router, prefix="/api/v1", tags=["API v1"])


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host=settings.host,
        port=settings.port,
        reload=not settings.is_production,
        log_level=settings.log_level.lower(),
    )
