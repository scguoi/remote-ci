"""Database connection and session management."""

from typing import Generator

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, declarative_base, sessionmaker

from ..core.config import settings

# Create database engine
engine = create_engine(
    settings.database_url,
    pool_pre_ping=True,
    pool_recycle=300,
    echo=not settings.is_production,  # Do not print SQL in production
)

# Create session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Declarative base class
Base = declarative_base()


def get_db() -> Generator[Session, None, None]:
    """Dependency injection function to get database session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
