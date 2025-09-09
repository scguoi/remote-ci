# GoDemo 用户服务（godemo）

一个使用 Gin + sqlx 实现的用户管理示例服务（对齐 backend-java 的功能与接口），演示常见的分层结构、MySQL 数据持久化、统一返回格式和乐观锁更新。

## 功能概览
- 用户 CRUD：创建、查询（ID/用户名/分页过滤）、更新（乐观锁）、软删除
- 校验：用户名/邮箱唯一性检查
- 健康检查：`GET /healthz`
- 统一响应：`{ success, message, data?, error?, timestamp }`

## 项目结构
```
backend-go/
├── cmd/server/           # 入口：启动 HTTP 服务
├── internal/
│   ├── common/           # 实体/DTO/错误码/通用响应
│   ├── dao/              # 数据访问（sqlx）
│   ├── service/          # 业务逻辑
│   └── handler/          # HTTP 路由与处理
└── migrations/           # 数据库迁移 SQL（users 表）
```

## 环境要求
- Go 1.21+
- MySQL 8.0+

## 配置与运行
1) 准备数据库并初始化表
- 创建数据库（如 demo），执行 `migrations/0001_create_users.sql`

2) 配置环境变量（必需）
- 复制 `.env.example` 为 `.env` 并填写：
```
PORT=8080
MYSQL_DSN="user:pass@tcp(127.0.0.1:3306)/demo?parseTime=true&charset=utf8mb4"
```

3) 启动服务（推荐使用统一 Make 命令）
```
# 在仓库根目录
make run-go
# 或：
cd backend-go && go run ./cmd/server
```
访问：http://localhost:8080/healthz

## 常用命令（统一 Make）
```
# 代码格式
make fmt-go         # 使用 goimports + gofumpt + golines 自动格式化
make fmt-check-go   # 仅检查是否已按 goimports/gofumpt 格式化（不修改）

# 质量与测试
make check-go       # 质量检查（gocyclo / staticcheck / golangci-lint）
make test-go        # 运行 Go 单元测试（internal/...）
make coverage-go    # 生成覆盖率报告（backend-go/coverage/coverage.html）

# 构建与运行
make build-go       # 构建二进制到 backend-go/bin/server
make run-go         # 启动服务（加载 backend-go/.env）
```

## API 速览（与 Java 版保持一致）
- POST `/api/v1/users` 创建用户
- GET `/api/v1/users/{id}` 按 ID 查询
- GET `/api/v1/users/username/{username}` 按用户名查询
- GET `/api/v1/users?is_active=&page=&size=&username=&email=` 列表/分页/过滤
- PUT `/api/v1/users/{id}` 更新（需 body.version）
- DELETE `/api/v1/users/{id}?version=1` 软删除（乐观锁）
- GET `/api/v1/users/check-username/{username}` 检查用户名是否存在
- GET `/api/v1/users/check-email?email=xxx@example.com` 检查邮箱是否存在

## 示例请求
```
# 创建用户
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
        "username":"alice",
        "email":"a@example.com",
        "full_name":"Alice",
        "password":"secret"
      }'

# 按 ID 查询
curl http://localhost:8080/api/v1/users/1

# 分页查询（过滤 is_active）
curl "http://localhost:8080/api/v1/users?is_active=true&page=0&size=10"

# 更新（需要当前 version）
curl -X PUT http://localhost:8080/api/v1/users/1 \
  -H "Content-Type: application/json" \
  -d '{
        "email":"alice@new.com",
        "version":1
      }'

# 软删除（乐观锁）
curl -X DELETE "http://localhost:8080/api/v1/users/1?version=2"
```

## 说明
- 乐观锁：通过 `version` 字段避免并发更新冲突；更新/删除需携带当前版本。
- 认证：handler 中当前将操作者模拟为 `system`，实际项目可接入 JWT/Session 中间件。
- 配置：`MYSQL_DSN` 必填；未设置会直接退出并提示配置示例。
- 覆盖率：执行 `make coverage-go` 后，打开 `backend-go/coverage/coverage.html` 查看图形化报告。

## 开发工作流建议
1) `make fmt-check-go` 确认格式；必要时 `make fmt-go` 一键修复。
2) `make test-go` 本地单测；需要覆盖率时用 `make coverage-go`。
3) `make check-go` 进行复杂度/静态检查；提交前确保通过。
4) `make build-go` 或 `make run-go` 验证服务端点。

## 许可证
遵循仓库根目录的 LICENSE。
