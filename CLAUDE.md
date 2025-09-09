# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Architecture

This is a **智能多语言CI/CD工具链**，支持Go、Java、Python和TypeScript项目的统一开发工作流。从95个复杂命令优化为15个智能命令，大幅提升开发者体验。

### Key Architecture Components

- **智能Makefile系统**: 15个核心命令替代原有95个命令
- **自动项目检测**: 智能识别Go、Java、Python、TypeScript项目
- **统一工作流**: format、check、test、build等操作自动适配所有语言
- **完美向后兼容**: 所有原有95个命令仍然可用
- **Git钩子管理**: 自动化的代码质量检查和提交规范

### 项目结构

```
remote-ci/
├── Makefile                    # 15个智能核心命令
├── makefiles/
│   ├── core/
│   │   ├── detection.mk        # 智能项目检测
│   │   └── workflows.mk        # 核心工作流
│   ├── go.mk                   # Go语言支持
│   ├── java.mk                 # Java/Maven支持  
│   ├── python.mk               # Python/FastAPI支持
│   ├── typescript.mk           # TypeScript/Node支持
│   └── git.mk                  # Git钩子和分支管理
├── backend-go/                 # Go微服务项目
├── backend-java/               # Java Spring Boot项目
├── backend-python/             # Python FastAPI项目
├── frontend-ts/                # TypeScript前端项目
└── archives/                   # 备份文件存档
```

### 智能检测机制

系统自动检测活跃项目并智能执行操作：
- **Go**: 检测`backend-go/go.mod`和`cmd/`目录
- **Java**: 检测`backend-java/pom.xml`和Maven模块
- **Python**: 检测`backend-python/main.py`和`requirements.txt`
- **TypeScript**: 检测`frontend-ts/package.json`和`tsconfig.json`

## Essential Commands - 新的智能命令体系

### 🚀 日常核心命令 (8个) - 零学习成本
```bash
make setup      # 🛠️ 一次性环境搭建 (工具+钩子+分支策略)
make format     # ✨ 智能格式化 (自动检测所有项目)
make check      # 🔍 智能质量检查 (自动检测所有项目)
make test       # 🧪 智能测试运行 (自动检测所有项目)
make build      # 📦 智能项目构建 (自动检测所有项目)
make dev        # 🚀 智能开发服务器 (根据上下文启动)
make push       # 📤 安全推送 (预检查+分支验证)
make clean      # 🧹 智能清理构建产物
```

### 🔧 专业命令 (5个)
```bash
make status     # 📊 显示详细项目状态
make info       # ℹ️ 显示工具和依赖信息
make lint       # 🔧 运行代码检查 (check的别名)
make fix        # 🛠️ 自动修复代码问题
make ci         # 🤖 完整CI流程 (format+check+test+build)
```

### ⚙️ 高级命令 (2个)
```bash
make hooks      # ⚙️ Git钩子管理菜单
make enable-legacy # 🔄 启用完整旧命令集 (向后兼容)
```

### 向后兼容 - 旧命令依然可用
```bash
make enable-legacy  # 启用后可以使用：
make fmt-go         # 原Go格式化命令
make check-java     # 原Java检查命令  
make test-python    # 原Python测试命令
# ... 所有95个原命令都保留
```

## 智能特性展示

### 自动项目检测
```bash
$ make status
检测到的活跃项目: go java python typescript
活跃项目数量: 4
多项目环境: true
```

### 上下文感知开发服务器
```bash
cd backend-go && make dev      # 启动Go服务
cd frontend-ts && make dev     # 启动TypeScript开发服务器
cd backend-python && make dev  # 启动Python FastAPI服务
make dev                       # 在根目录显示选项菜单
```

### 智能批量操作
```bash
make format  # 自动格式化所有4种语言的代码
make check   # 自动检查所有4种语言的代码质量
make test    # 自动运行所有3种语言的测试 (TypeScript暂跳过)
```

## Code Quality Standards

### 多语言统一标准
- **Go**: gofmt + goimports + gofumpt + golines + staticcheck + golangci-lint
- **Java**: Spotless + Checkstyle + PMD + SpotBugs  
- **Python**: black + isort + flake8 + mypy + pylint
- **TypeScript**: prettier + eslint + tsc

### Quality Gates
- **代码格式**: 必须通过各语言的格式化工具
- **静态分析**: 必须通过各语言的静态检查工具
- **类型检查**: TypeScript和Python必须通过类型检查
- **提交规范**: 遵循Conventional Commits格式
- **分支命名**: 遵循`feature-*`、`bugfix-*`、`hotfix-*`模式

## Development Workflow

### 推荐的开发流程
```bash
# 1. 环境搭建 (仅需一次)
make setup

# 2. 日常开发循环
make format     # 格式化代码
make check      # 质量检查
make test       # 运行测试  
make push       # 安全推送

# 3. 项目发布
make ci         # 完整CI流程
make build      # 构建所有项目
```

### Git钩子自动化
- **pre-commit**: 自动格式化 + 质量检查
- **commit-msg**: 验证提交消息格式
- **pre-push**: 验证分支命名规范

## Troubleshooting

### 工具相关问题
```bash
make info           # 查看所有工具状态
make check-tools-go # 检查Go工具
make install-tools  # 重新安装所有工具
```

### 项目检测问题
```bash
make _debug         # 显示检测调试信息
make status         # 显示项目状态详情
```

### 性能优化
- 使用`make hooks-install-basic`安装轻量级钩子
- 大项目可以分别在子目录中运行命令
- CI环境推荐使用`make ci`进行完整检查

## 重要提醒

### 这是多语言工具链项目
- **核心价值**: 统一的多语言开发工作流，而不是单一应用
- **智能化**: 自动检测项目类型，零配置使用
- **向后兼容**: 保留所有原有功能，平滑迁移

### 优化成果
- **命令简化**: 从95个命令减少到15个核心命令 (减少84%)
- **零学习成本**: 开发者只需记住8个日常命令
- **智能化操作**: 一个命令处理多种语言
- **完美兼容**: 所有旧命令仍可使用

详细文档请参考：`Makefile-readme.md`