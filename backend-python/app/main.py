"""FastAPI application main entry point."""

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
    """Application lifecycle management."""
    # On startup: create database tables (will be overridden during testing)
    try:
        Base.metadata.create_all(bind=engine)
        print(f"🚀 {settings.project_name} started successfully")
        print(f"📖 API Documentation: http://{settings.host}:{settings.port}/docs")
    except Exception as e:
        # Connection errors may occur during testing, which is normal
        if "test" not in settings.database_url.lower():
            print(f"⚠️ Database connection warning: {e}")
        pass
    yield
    # Cleanup work on shutdown
    print(f"🛑 {settings.project_name} has stopped")


# Create FastAPI application instance
app = FastAPI(
    title=settings.project_name,
    description=settings.description,
    version=settings.version,
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Global exception handler."""
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content=APIResponse(
            success=False,
            message="Internal server error",
            error=str(exc) if not settings.is_production else "Internal Server Error",
        ).model_dump(),
    )


# Health check endpoint
@app.get("/healthz", response_model=HealthResponse, tags=["Health Check"])
async def health_check():
    """Service health check."""
    return HealthResponse(
        status="healthy", timestamp=datetime.utcnow(), version=settings.version
    )


@app.get("/", response_model=APIResponse, tags=["Root Path"])
async def root():
    """Root path welcome message."""
    return APIResponse(
        success=True,
        message=f"Welcome to {settings.project_name}",
        data={
            "version": settings.version,
            "docs_url": "/docs",
            "health_check": "/healthz",
        },
    )


# Register API routes
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
