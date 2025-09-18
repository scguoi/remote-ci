#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Python backend service entry point
Runs FastAPI user management service
"""

import uvicorn

from app.core.config import settings


def main() -> None:
    """Start FastAPI service."""
    print(f"🚀 Starting {settings.project_name}")
    print(f"🌐 Service URL: http://{settings.host}:{settings.port}")
    print(f"📖 API Documentation: http://{settings.host}:{settings.port}/docs")
    print("Welcome to Python Backend Service")

    uvicorn.run(
        "app.main:app",
        host=settings.host,
        port=settings.port,
        reload=not settings.is_production,
        log_level=settings.log_level.lower() if settings.log_level else "info",
    )


if __name__ == "__main__":
    main()
