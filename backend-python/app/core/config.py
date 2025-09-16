"""Application configuration management."""

import os
from typing import List

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings class."""

    model_config = SettingsConfigDict(
        env_file=".env", env_file_encoding="utf-8", case_sensitive=False
    )

    # Server configuration
    port: int = Field(8000, description="Service port")
    host: str = Field("127.0.0.1", description="Service host")

    # Database configuration
    database_url: str = Field(
        "mysql+pymysql://user:password@localhost:3306/demo?charset=utf8mb4",
        description="Database connection URL",
    )

    # JWT configuration
    secret_key: str = Field("your-secret-key", description="JWT secret key")
    algorithm: str = Field("HS256", description="JWT algorithm")
    access_token_expire_minutes: int = Field(
        30, description="Token expiration time (minutes)"
    )

    # Logging configuration
    log_level: str = Field("INFO", description="Log level")

    # CORS configuration
    allowed_origins: List[str] = Field(
        ["http://localhost:3000", "http://localhost:8080"],
        description="Allowed CORS origins",
    )

    # Project information
    project_name: str = Field("Python User API", description="Project name")
    version: str = Field("1.0.0", description="Project version")
    description: str = Field(
        "FastAPI user management service", description="Project description"
    )

    @property
    def is_production(self) -> bool:
        """Check if it is production environment."""
        return os.getenv("ENV", "development").lower() == "production"


# Global configuration instance
settings = Settings()
