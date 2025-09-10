# Docker 部署指南

本项目为每个工程创建了独立的Dockerfile，并提供了docker-compose.yml进行统一管理。

## 🏗️ 架构概览

```
┌─────────────────────────────────────────────────────────────┐
│                      Docker 容器架构                        │
├─────────────────────────────────────────────────────────────┤
│  Frontend (Nginx)     │  Backend Services  │   Database     │
│  ┌─────────────────┐  │  ┌──────────────┐  │  ┌──────────┐  │
│  │  TypeScript     │  │  │   Go Service │  │  │  MySQL   │  │
│  │  + Vite         │  │  │   :8080      │  │  │  :3306   │  │
│  │  + Nginx :80    │  │  └──────────────┘  │  └──────────┘  │
│  └─────────────────┘  │  ┌──────────────┐  │               │
│                       │  │ Java Service │  │               │
│                       │  │   :8081      │  │               │
│                       │  └──────────────┘  │               │
│                       │  ┌──────────────┐  │               │
│                       │  │Python Service│  │               │
│                       │  │   :8000      │  │               │
│                       │  └──────────────┘  │               │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Docker 文件结构

```
remote-ci/
├── docker-compose.yml          # 服务编排文件
├── scripts/
│   ├── docker-dev.sh          # 开发环境管理脚本
│   └── init.sql               # MySQL初始化脚本
├── backend-go/
│   ├── Dockerfile             # Go服务容器
│   └── .dockerignore
├── backend-java/
│   ├── Dockerfile             # Java服务容器
│   └── .dockerignore
├── backend-python/
│   ├── Dockerfile             # Python服务容器
│   └── .dockerignore
└── frontend-ts/
    ├── Dockerfile             # 前端容器
    ├── nginx.conf            # Nginx配置
    └── .dockerignore
```

## 🚀 快速开始

### 方法一：使用管理脚本 (推荐)

```bash
# 启动所有服务
./scripts/docker-dev.sh start

# 查看服务状态
./scripts/docker-dev.sh status

# 查看健康状态
./scripts/docker-dev.sh health

# 查看日志
./scripts/docker-dev.sh logs

# 停止所有服务
./scripts/docker-dev.sh stop
```

### 方法二：直接使用docker-compose

```bash
# 启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止所有服务
docker-compose down
```

## 🌐 服务访问地址

启动成功后，可以通过以下地址访问各个服务：

- **前端应用**: http://localhost (端口80)
- **Go后端**: http://localhost:8080
- **Java后端**: http://localhost:8081  
- **Python后端**: http://localhost:8000
- **MySQL数据库**: localhost:3306

## 🔧 开发命令

```bash
# 构建所有镜像
./scripts/docker-dev.sh build

# 重启所有服务
./scripts/docker-dev.sh restart

# 查看特定服务日志
./scripts/docker-dev.sh logs backend-go

# 清理所有容器和资源
./scripts/docker-dev.sh cleanup
```

## 🏥 健康检查

所有服务都配置了健康检查：

- **Go服务**: `GET /health`
- **Java服务**: `GET /actuator/health`
- **Python服务**: `GET /health`
- **前端服务**: `GET /health`
- **MySQL**: `mysqladmin ping`

## 📊 资源配置

### 内存配置
- **Go服务**: ~50MB
- **Java服务**: 512MB (可通过JAVA_OPTS调整)
- **Python服务**: ~100MB
- **前端服务**: ~20MB
- **MySQL**: ~400MB

### 端口映射
```yaml
mysql:        3306 -> 3306
backend-go:   8080 -> 8080
backend-java: 8081 -> 8080 (内部)
backend-python: 8000 -> 8000
frontend-ts:  80 -> 80
```

## 🛠️ 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 检查端口使用情况
   lsof -i :80
   lsof -i :8080
   lsof -i :8081
   lsof -i :8000
   ```

2. **服务启动失败**
   ```bash
   # 查看详细日志
   docker-compose logs [service-name]
   
   # 重新构建镜像
   ./scripts/docker-dev.sh build
   ```

3. **数据库连接问题**
   ```bash
   # 检查MySQL容器状态
   docker-compose logs mysql
   
   # 手动连接测试
   docker-compose exec mysql mysql -u app_user -p user_db
   ```

4. **健康检查失败**
   ```bash
   # 检查服务健康状态
   ./scripts/docker-dev.sh health
   
   # 查看容器状态
   docker-compose ps
   ```

### 日志位置

```bash
# 查看所有服务日志
docker-compose logs

# 查看特定服务日志
docker-compose logs backend-go
docker-compose logs mysql

# 实时跟踪日志
docker-compose logs -f --tail=100
```

## 🔒 安全特性

- ✅ 所有服务使用非root用户运行
- ✅ 使用多阶段构建优化镜像大小
- ✅ 配置.dockerignore避免敏感文件
- ✅ 前端配置安全头部
- ✅ 健康检查确保服务可用性
- ✅ 网络隔离使用专用网络

## 🚀 生产环境注意事项

1. **环境变量**: 生产环境需要配置真实的数据库密码和API密钥
2. **SSL证书**: 前端服务建议配置HTTPS
3. **数据持久化**: MySQL数据已配置volume持久化
4. **监控日志**: 建议集成ELK或其他日志监控系统
5. **资源限制**: 根据实际负载调整容器资源限制

## 📚 相关文档

- [项目主文档](./README.md)
- [智能Makefile文档](./Makefile-readme.md)
- [架构设计文档](./CLAUDE.md)