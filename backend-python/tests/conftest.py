"""Test configuration and common fixtures."""

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

# Set test environment variables
os.environ["DATABASE_URL"] = "sqlite:///./test.db"

# Use in-memory SQLite database for testing
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)

TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    """Test database session dependency."""
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


# Create test-specific FastAPI app (without lifespan)
def create_test_app():
    """Create FastAPI app for testing."""
    test_app = FastAPI(
        title=settings.project_name,
        description=settings.description,
        version=settings.version,
        # Don't use lifespan to avoid database connection issues
    )

    # Health check endpoint
    @test_app.get("/healthz", response_model=HealthResponse, tags=["Health Check"])
    async def health_check():
        """Service health check."""
        from datetime import datetime

        return HealthResponse(
            status="healthy", timestamp=datetime.utcnow(), version=settings.version
        )

    @test_app.get("/", response_model=APIResponse, tags=["Root Path"])
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
    test_app.include_router(users.router, prefix="/api/v1", tags=["API v1"])

    return test_app


@pytest.fixture(scope="function")
def db_session():
    """Create test database session."""
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def client(db_session):
    """Create test client."""
    test_app = create_test_app()
    test_app.dependency_overrides[get_db] = override_get_db

    with TestClient(test_app) as test_client:
        yield test_client

    test_app.dependency_overrides.clear()
