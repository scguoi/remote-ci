# 🐳 Build-Push Workflow 使用指南

这个GitHub Actions workflow可以自动构建你的多语言项目的Docker镜像，并推送到GitHub Container Registry (GHCR)。

## 🎯 功能特性

### ✨ 智能特性
- **🔍 智能项目检测**: 自动检测Go、Java、Python、TypeScript项目
- **🏗️ 多架构构建**: 支持AMD64和ARM64架构
- **📦 GitHub集成**: 推送到GitHub Container Registry，无需额外配置
- **⚡ 并行构建**: 4个服务同时构建，提升效率
- **🎮 手动触发**: 支持手动触发构建和推送

### 🐳 构建的镜像
| 服务 | GitHub Container Registry |
|------|---------------------------|
| **Go后端** | `ghcr.io/scguoi/remote-ci-go` |
| **Java后端** | `ghcr.io/scguoi/remote-ci-java` |
| **Python后端** | `ghcr.io/scguoi/remote-ci-python` |
| **前端** | `ghcr.io/scguoi/remote-ci-frontend` |

## 🚀 触发条件

### 自动触发
```yaml
# 推送到主分支时自动构建并推送
git push origin main

# 推送到发布分支时自动构建并推送  
git push origin release/v1.0.0

# 创建标签时自动构建并推送
git tag v1.0.0
git push origin v1.0.0

# Pull Request时只构建不推送
git push origin feature/new-feature
```

### 手动触发
1. 访问GitHub仓库的Actions页面
2. 选择"Build and Push Multi-Language Images"
3. 点击"Run workflow"
4. 选择分支和是否推送镜像

## ⚙️ 配置要求

### ✅ 零配置启用！
GitHub Container Registry (GHCR) 使用内置的 `GITHUB_TOKEN`，**无需任何额外配置**！

推送后workflow会自动：
- 检测你的项目
- 构建Docker镜像 
- 推送到 `ghcr.io/your-username/your-repo-name-service`

### 🔧 可选配置

如果你想自定义镜像可见性：
1. 进入仓库 → **Packages** 标签页
2. 选择镜像 → **Package settings**
3. 设置为Public（公开）或Private（私有）

## 🏷️ 镜像标签策略

| 触发条件 | 标签示例 | 说明 |
|----------|----------|------|
| **主分支推送** | `latest` | 最新稳定版本 |
| **标签推送** | `v1.0.0`, `1.0` | 语义化版本 |
| **分支推送** | `feature-new-ui` | 特性分支名称 |
| **PR构建** | `pr-123` | Pull Request编号 |

## 📊 构建流程

### Stage 1: 检测和元数据 (2分钟)
- 🔍 自动检测项目类型
- 📋 提取版本和标签信息
- 🎯 确定构建平台和推送策略

### Stage 2: 并行Docker构建 (5-10分钟)
- 🐹 Go服务构建 (Alpine多阶段)
- ☕ Java服务构建 (Eclipse Temurin 21)
- 🐍 Python服务构建 (Python 3.11 Slim)
- 🟦 TypeScript前端构建 (Node 18 + Nginx)

### Stage 3: 构建总结 (1分钟)
- 📊 生成详细的构建报告
- ✅ 验证所有镜像构建成功
- 🚀 展示发布的镜像列表

## 🔍 使用镜像

### Docker Compose方式
```yaml
version: '3.8'
services:
  backend-go:
    image: ghcr.io/scguoi/remote-ci-go:latest
    ports:
      - "8080:8080"
  
  backend-java:
    image: ghcr.io/scguoi/remote-ci-java:latest
    ports:
      - "8081:8080"
      
  backend-python:
    image: ghcr.io/scguoi/remote-ci-python:latest
    ports:
      - "8000:8000"
      
  frontend:
    image: ghcr.io/scguoi/remote-ci-frontend:latest
    ports:
      - "80:80"
```

### 单独运行
```bash
# Go服务
docker run -p 8080:8080 ghcr.io/scguoi/remote-ci-go:latest

# Java服务  
docker run -p 8081:8080 ghcr.io/scguoi/remote-ci-java:latest

# Python服务
docker run -p 8000:8000 ghcr.io/scguoi/remote-ci-python:latest

# 前端服务
docker run -p 80:80 ghcr.io/scguoi/remote-ci-frontend:latest
```

## 🐛 故障排除

### 常见问题

**1. 项目未检测到**
```bash
⚠️ No Docker projects detected
```
- 确认项目目录包含`Dockerfile`
- 检查项目结构是否符合预期

**2. 构建超时**
- Java项目构建可能需要更长时间
- 考虑调整timeout设置或优化Dockerfile

**3. 权限问题**
- GHCR推送使用内置`GITHUB_TOKEN`，无需额外配置
- 如果遇到权限错误，检查仓库的Actions权限设置

### 调试方法

**查看构建日志**:
1. GitHub → Actions → 选择失败的workflow
2. 点击具体的job查看详细日志
3. 展开具体步骤查看错误信息

**本地测试构建**:
```bash
# 测试单个服务构建
docker build -t test-image backend-go/

# 测试多架构构建
docker buildx build --platform linux/amd64,linux/arm64 backend-go/
```

## 📈 优化建议

### 1. 构建优化
- 使用多阶段构建减小镜像体积
- 利用GitHub Actions缓存加速构建
- 优化Dockerfile的层顺序

### 2. 安全优化
- GHCR使用GitHub内置权限管理，更安全
- 支持私有镜像（私有仓库自动私有镜像）
- 启用镜像签名验证

### 3. 性能优化
- 合理使用构建缓存
- 并行构建多个镜像
- 优化依赖安装过程

## 🔧 高级配置

### 自定义构建参数
```yaml
build-args: |
  VERSION=${{ needs.detect-and-prepare.outputs.version }}
  GIT_COMMIT=${{ github.sha }}
  BUILD_TIME=${{ github.run_id }}
  CUSTOM_ARG=value
```

### 条件构建
```yaml
# 只在特定条件下构建
if: |
  needs.detect-and-prepare.outputs.has-go == 'true' && 
  (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/'))
```

### 多环境支持
```yaml
# 不同环境使用不同配置
- name: Set environment specific values
  run: |
    if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
      echo "ENV=production" >> $GITHUB_ENV
    else
      echo "ENV=staging" >> $GITHUB_ENV
    fi
```

## 📚 相关文档

- [Docker官方文档](https://docs.docker.com/)
- [GitHub Actions文档](https://docs.github.com/en/actions)
- [Docker Hub文档](https://docs.docker.com/docker-hub/)
- [GitHub Container Registry文档](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)

---

## 🎉 享受自动化的多语言Docker构建体验！

有问题或建议？欢迎提交Issue或Pull Request。