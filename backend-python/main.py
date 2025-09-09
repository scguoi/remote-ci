#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Python后端服务入口文件
运行FastAPI用户管理服务
"""

import uvicorn

from app.core.config import settings


def main() -> None:
    """启动FastAPI服务."""
    print(f"🚀 启动 {settings.project_name}")
    print(f"🌐 服务地址: http://{settings.host}:{settings.port}")
    print(f"📖 API文档: http://{settings.host}:{settings.port}/docs")
    print("欢迎使用Python后端服务")

    uvicorn.run(
        "app.main:app",
        host=settings.host,
        port=settings.port,
        reload=not settings.is_production,
        log_level=settings.log_level.lower() if settings.log_level else "info",
    )


if __name__ == "__main__":
    main()
