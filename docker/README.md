# Docker 部署目录

此目录包含了remote-ci项目的完整Docker部署方案。

## 📁 目录结构

```
docker/
├── docker-compose.yml    # 服务编排文件
├── docker-dev.sh        # 开发环境管理脚本
├── DOCKER.md            # 详细部署指南
└── README.md           # 本文件
```

## 🚀 快速开始

### 方法一：使用管理脚本 (推荐)

```bash
# 进入docker目录
cd docker

# 启动所有服务
./docker-dev.sh start

# 查看服务状态
./docker-dev.sh status

# 停止所有服务
./docker-dev.sh stop
```

### 方法二：直接使用docker-compose

```bash
# 进入docker目录
cd docker

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

## 🔧 可用命令

```bash
# 构建所有镜像
./docker-dev.sh build

# 重启所有服务
./docker-dev.sh restart

# 查看特定服务日志
./docker-dev.sh logs backend-go

# 清理所有容器和资源
./docker-dev.sh cleanup

# 健康检查
./docker-dev.sh health
```

## 📚 详细文档

更多详细信息请参考：
- [完整部署指南](./DOCKER.md)
- [项目主文档](../README.md)
- [架构设计文档](../CLAUDE.md)

## ⚠️ 注意事项

1. **工作目录**: 所有docker命令都需要在此`docker/`目录下执行
2. **路径引用**: docker-compose.yml中使用相对路径`../`引用项目源码
3. **数据初始化**: MySQL使用`../scripts/init.sql`进行数据库初始化