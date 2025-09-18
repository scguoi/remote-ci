# Python用户服务（backend-python）

一个使用 FastAPI + SQLAlchemy 实现的用户管理示例服务，演示Clean Architecture架构、MySQL数据持久化、统一响应格式和乐观锁更新。与backend-go保持功能一致，提供相同的API接口。

## 功能概览
- 用户 CRUD：创建、查询（ID/用户名/分页过滤）、更新（乐观锁）、软删除
- 校验：用户名/邮箱唯一性检查、数据验证（Pydantic）
- 健康检查：`GET /healthz`
- API文档：自动生成的Swagger UI
- 统一响应：`{ success, message, data?, error?, timestamp }`

## 项目结构
```
backend-python/
├── app/
│   ├── api/
│   │   └── v1/            # API路由层
│   │       └── users.py   # 用户相关端点
│   ├── core/
│   │   ├── models.py      # SQLAlchemy数据库模型
│   │   ├── schemas.py     # Pydantic数据验证模式
│   │   ├── security.py    # 密码加密、JWT工具
│   │   ├── config.py      # 应用配置管理
│   │   └── services/      # 业务逻辑服务层
│   │       └── user_service.py
│   ├── db/
│   │   ├── database.py    # 数据库连接配置
│   │   ├── dao/           # 数据访问对象
│   │   │   └── user_dao.py
│   │   └── migrations/    # 数据库迁移SQL
│   └── main.py           # FastAPI应用入口
├── tests/                # 测试目录
│   ├── unit/             # 单元测试
│   ├── integration/      # 集成测试
│   └── conftest.py       # pytest配置
├── .env.example          # 环境变量示例
├── requirements.txt      # Python依赖
└── pyproject.toml       # 项目配置与工具设置
```

## 环境要求
- Python 3.9+
- MySQL 8.0+
- 推荐使用虚拟环境

## 配置与运行

### 1) 安装依赖
```bash
# 在仓库根目录
make install-deps-python
# 或：
cd backend-python && pip install -r requirements.txt
```

### 2) 准备数据库并初始化表
- 创建数据库（如 demo），执行 `app/db/migrations/0001_create_users.sql`
- 或运行服务时自动创建表（SQLAlchemy）

### 3) 配置环境变量（必需）
- 复制 `.env.example` 为 `.env` 并填写：
```bash
PORT=8000
DATABASE_URL="mysql+pymysql://user:password@localhost:3306/demo?charset=utf8mb4"
SECRET_KEY="your-secret-key-change-in-production"
```

### 4) 启动服务（推荐使用统一 Make 命令）
```bash
# 在仓库根目录
make run-python
# 或：
cd backend-python && python main.py
```
访问：
- 服务地址：http://localhost:8000
- API文档：http://localhost:8000/docs
- 健康检查：http://localhost:8000/healthz

## 常用命令（统一 Make）

### 代码格式化
```bash
make fmt-python         # 使用 black + isort 自动格式化
make fmt-check-python   # 仅检查格式（不修改文件）
```

### 质量检查与测试
```bash
make check-python       # 完整质量检查（flake8 + mypy + pylint）
make lint-python        # 综合linting检查
make test-python        # 运行单元测试和集成测试
make coverage-python    # 生成测试覆盖率报告（HTML: coverage_html/index.html）
```

### 开发工具
```bash
make install-tools-python  # 安装开发工具（black、isort、pytest等）
make check-tools-python    # 检查工具安装状态
make install-deps-python   # 安装项目依赖
```

## API 接口（与Go版保持一致）

### 核心用户管理
- `POST /api/v1/users/` 创建用户
- `GET /api/v1/users/{id}` 按 ID 查询
- `GET /api/v1/users/username/{username}` 按用户名查询
- `GET /api/v1/users?is_active=&page=&size=&username=&email=` 列表/分页/过滤
- `PUT /api/v1/users/{id}` 更新（需 body.version）
- `DELETE /api/v1/users/{id}?version=1` 软删除（乐观锁）

### 验证功能
- `GET /api/v1/users/check-username/{username}` 检查用户名是否存在
- `GET /api/v1/users/check-email?email=xxx@example.com` 检查邮箱是否存在

### 系统功能
- `GET /healthz` 健康检查
- `GET /` 根路径欢迎信息
- `GET /docs` Swagger API文档

## 示例请求

### 创建用户
```bash
curl -X POST http://localhost:8000/api/v1/users/ \\
  -H "Content-Type: application/json" \\
  -d '{
        "username":"alice",
        "email":"alice@example.com",
        "full_name":"Alice Johnson",
        "password":"secret123"
      }'
```

### 按ID查询
```bash
curl http://localhost:8000/api/v1/users/1
```

### 分页查询（过滤激活用户）
```bash
curl "http://localhost:8000/api/v1/users?is_active=true&page=0&size=10"
```

### 更新用户（需要当前version）
```bash
curl -X PUT http://localhost:8000/api/v1/users/1 \\
  -H "Content-Type: application/json" \\
  -d '{
        "email":"alice.new@example.com",
        "version":1
      }'
```

### 软删除（乐观锁）
```bash
curl -X DELETE "http://localhost:8000/api/v1/users/1?version=2"
```

## 架构特性

### Clean Architecture分层
- **API层**：FastAPI路由，HTTP请求处理
- **Service层**：业务逻辑，数据验证，事务管理
- **DAO层**：数据访问，SQL操作，乐观锁实现
- **Model层**：数据模型定义，数据库映射

### 数据验证与安全
- **Pydantic验证**：自动输入验证，类型安全
- **密码加密**：bcrypt哈希存储
- **乐观锁**：version字段防止并发更新冲突
- **软删除**：deleted_at字段标记，保留数据完整性

### 开发工具链
- **代码格式**：black（格式化）+ isort（导入排序）
- **质量检查**：flake8（语法）+ mypy（类型）+ pylint（静态分析）
- **测试框架**：pytest + pytest-cov（覆盖率）
- **API文档**：自动生成Swagger UI

## 测试说明

### 运行测试
```bash
# 运行所有测试
make test-python

# 生成覆盖率报告
make coverage-python

# 查看HTML覆盖率报告
open backend-python/coverage_html/index.html
```

### 测试结构
- **单元测试**：业务逻辑Service层测试
- **集成测试**：完整API端点测试
- **数据库测试**：使用SQLite内存数据库

## 开发工作流建议
1. **格式检查**：`make fmt-check-python` 确认格式；必要时 `make fmt-python` 修复
2. **质量检查**：`make check-python` 进行语法、类型、静态分析检查
3. **运行测试**：`make test-python` 验证功能；`make coverage-python` 检查覆盖率
4. **启动服务**：`make run-python` 验证API端点

## 与Go版本的兼容性
- **API接口完全一致**：相同的端点、请求格式、响应结构
- **数据库表结构兼容**：可以共享相同的MySQL数据库
- **业务逻辑一致**：乐观锁、软删除、验证规则保持同步
- **统一的Make命令**：开发工作流与Go版本保持一致

## 许可证
遵循仓库根目录的 LICENSE。