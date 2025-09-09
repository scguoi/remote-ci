"""应用配置管理."""

import os
from typing import List

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """应用配置类."""

    model_config = SettingsConfigDict(
        env_file=".env", env_file_encoding="utf-8", case_sensitive=False
    )

    # 服务配置
    port: int = Field(8000, description="服务端口")
    host: str = Field("127.0.0.1", description="服务地址")

    # 数据库配置
    database_url: str = Field(
        "mysql+pymysql://user:password@localhost:3306/demo?charset=utf8mb4",
        description="数据库连接URL",
    )

    # JWT配置
    secret_key: str = Field("your-secret-key", description="JWT密钥")
    algorithm: str = Field("HS256", description="JWT算法")
    access_token_expire_minutes: int = Field(30, description="令牌过期时间（分钟）")

    # 日志配置
    log_level: str = Field("INFO", description="日志级别")

    # CORS配置
    allowed_origins: List[str] = Field(
        ["http://localhost:3000", "http://localhost:8080"], description="允许的CORS来源"
    )

    # 项目信息
    project_name: str = Field("Python User API", description="项目名称")
    version: str = Field("1.0.0", description="项目版本")
    description: str = Field("FastAPI用户管理服务", description="项目描述")

    @property
    def is_production(self) -> bool:
        """检查是否为生产环境."""
        return os.getenv("ENV", "development").lower() == "production"


# 全局配置实例
settings = Settings()
