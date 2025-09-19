# 🚀 智能多语言CI/CD工具链

[![统一工作流](https://img.shields.io/badge/workflow-unified-blue)](#核心特性)
[![多语言支持](https://img.shields.io/badge/languages-4-orange)](#支持的语言)
[![智能命令](https://img.shields.io/badge/commands-15-green)](#完整命令参考)
[![TypeScript全局工具](https://img.shields.io/badge/TypeScript-global--tools-red)](#支持的语言)

> **统一的多语言开发工作流，支持Go、Java、Python、TypeScript四种语言的智能CI/CD工具链**

## 🎯 项目简介

这是一个**智能多语言CI/CD工具链**，通过统一的Makefile系统为Go、Java、Python、TypeScript项目提供完整的开发工作流支持。

### 🎯 核心设计理念

**智能化**：自动检测项目类型，无需手动配置
**统一化**：一套命令适配所有语言的开发流程
**简洁化**：15个核心命令覆盖所有开发场景

### ✨ 核心特性

- **🧠 智能检测**: 基于文件特征和配置的项目类型识别
- **🎯 简洁命令**: 15个核心命令覆盖所有开发场景
- **🔄 完美兼容**: 所有专用语言命令依然可用
- **⚡ 零学习成本**: 只需记住7个日常命令
- **🛠️ 统一工作流**: 一套命令适配多种语言
- **🌐 TypeScript全局工具**: 避免项目依赖冲突
- **📄 灵活配置**: 支持TOML配置驱动的项目管理

## 🏗️ 支持的语言与技术栈

| 语言 | 主要框架 | 开发工具链 | 质量检查工具 | 特殊配置 |
|------|----------|------------|-------------|----------|
| **Go** | Gin, GORM, Echo | gofmt, goimports, gofumpt | staticcheck, golangci-lint | - |
| **Java** | Spring Boot, Maven | Spotless, Checkstyle | PMD, SpotBugs | - |
| **Python** | FastAPI, Flask, Django | black, isort | flake8, mypy, pylint | - |
| **TypeScript** | React, Vue, Node.js | prettier, eslint | tsc类型检查 | ✅ 全局工具安装 |

### 🛠️ 质量工具链

- **Go**: `gofmt` → `goimports` → `gofumpt` → `golines` → `staticcheck` → `golangci-lint`
- **Java**: `Spotless` → `Checkstyle` → `PMD` → `SpotBugs`
- **Python**: `black` → `isort` → `flake8` → `mypy` → `pylint`
- **TypeScript**: `prettier` → `eslint` → `tsc` (全局安装，避免依赖冲突)

## 🚀 快速开始

### 本地开发环境

```bash
# 1. 一次性环境搭建
make setup    # 安装所有语言工具 + 配置Git钩子

# 2. 日常开发流程
make format   # ✨ 智能格式化所有语言代码
make check    # 🔍 智能质量检查所有项目
make test     # 🧪 运行所有项目测试
make build    # 📦 构建所有项目
make push     # 📤 安全推送 (自动预检查)
```

就这么简单！一套命令适配所有语言。

## 📋 完整命令参考

### 🏆 日常核心命令 (7个) - 零学习成本

| 命令 | 功能 | 智能特性 |
|------|------|----------|
| `make setup` | 环境搭建 | 一次性安装所有语言工具 + Git钩子 |
| `make format` | 代码格式化 | 自动检测并格式化所有4种语言 |
| `make check` | 质量检查 | 自动运行所有4种语言的质量检查 |
| `make test` | 运行测试 | 自动运行Go/Java/Python测试 |
| `make build` | 项目构建 | 智能构建Go和Java项目 |
| `make push` | 安全推送 | 预检查+分支验证+自动推送 |
| `make clean` | 清理构建产物 | 清理所有语言的构建缓存 |

### 🔧 专业命令 (5个)

| 命令 | 功能 |
|------|------|
| `make status` | 显示项目检测状态和统计信息 |
| `make info` | 显示所有语言的工具安装状态 |
| `make lint` | 代码检查 (check命令的别名) |
| `make fix` | 自动修复代码问题 |
| `make ci` | 完整CI流程 (format+check+test+build) |

### ⚙️ 高级命令 (3个)

| 命令 | 功能 |
|------|------|
| `make hooks` | Git钩子管理菜单 |
| `make enable-legacy` | 启用完整的专用语言命令 |
| `make _debug` | 调试项目检测机制 |

## 🧠 智能特性展示

### 🧪 自动项目检测
```bash
$ make status
检测到的活跃项目: go java python typescript
智能检测机制: 基于文件特征识别
工作流模式: 统一命令适配
当前上下文: 多语言开发环境

工具链状态:
  ✅ Go工具链完整
  ✅ Java Maven配置正常
  ✅ Python虚拟环境就绪
  ✅ TypeScript全局工具可用
```

### 本地运行各服务
```bash
# 在各自项目目录运行原生命令
cd your-go-project && go run main.go              # → Go服务
cd your-java-project && mvn spring-boot:run       # → Spring Boot应用
cd your-python-project && python main.py          # → Python API服务
cd your-ts-project && npm run dev                 # → TypeScript开发服务器
```

### 智能批量操作
```bash
# 一个命令，处理所有语言
make format  # 同时格式化Go、Java、Python、TypeScript代码
make check   # 同时检查所有语言的代码质量
make test    # 同时运行Go、Java、Python的测试
```

## 📁 工具链架构

```
remote-ci/
├── 🎯 Makefile                     # 15个智能核心命令
├── 📂 makefiles/
│   ├── 🧠 core/
│   │   ├── detection.mk            # 智能项目检测引擎
│   │   └── workflows.mk            # 核心工作流实现
│   ├── 🐹 go.mk                    # Go语言支持 (7个统一命令)
│   ├── ☕ java.mk                  # Java/Maven支持 (7个统一命令)
│   ├── 🐍 python.mk               # Python支持 (7个统一命令)
│   ├── 📘 typescript.mk           # TypeScript/Node支持 (7个统一命令)
│   └── 🌿 git.mk                   # Git钩子和分支管理 (21个命令)
├── 📜 scripts/
│   └── parse_localci.sh           # 配置解析脚本
├── 🧪 makefile-tests/
│   ├── test_makefile.sh          # 全面测试脚本
│   └── quick_test.sh             # 快速测试脚本
├── .localci.toml                  # 项目配置文件 (可选)
└── 📚 docs/
    ├── Makefile-readme.md         # 详细技术文档 (英文版)
    └── Makefile-readme-zh.md      # 详细技术文档 (中文版)
```

### 🎯 设计原则

- **模块化**: 每种语言独立的.mk文件
- **标准化**: 统一的7命令接口
- **可扩展**: 易于添加新语言支持
- **智能化**: 自动检测和适配

## 🔧 高级功能

### Git钩子自动化
```bash
make hooks              # 显示钩子管理菜单
make hooks-install      # 安装完整钩子 (推荐)
make hooks-install-basic # 安装轻量级钩子 (更快)
```

自动启用的钩子：
- **pre-commit**: 自动格式化 + 代码质量检查
- **commit-msg**: 验证提交消息格式 (Conventional Commits)
- **pre-push**: 验证分支命名规范

### 向后兼容性
```bash
make enable-legacy  # 启用完整的专用语言命令

# 然后可以使用所有原始命令：
make fmt-go                    # Go格式化
make check-java               # Java质量检查
make test-python              # Python测试
make install-tools-typescript # TypeScript工具安装
# ... 所有专用命令都保留
```

### TypeScript全局工具优势
```bash
# 全局安装，避免项目依赖冲突
npm install -g typescript prettier eslint

# 直接使用，无需npx前缀
prettier --write "**/*.{ts,tsx,js,jsx}"
eslint "**/*.{ts,tsx,js,jsx}"
tsc --noEmit
```

### 调试和故障排除
```bash
make _debug          # 显示项目检测调试信息
make info           # 查看所有工具安装状态
make check-tools-go # 检查特定语言工具状态
```

## 📈 工具链优势

| 特性 | 传统方式 | 智能工具链 | 优势 |
|------|----------|-----------|------|
| **命令复杂度** | 每种语言不同命令 | 统一的15个命令 | ⬇️ 认知负担 |
| **学习成本** | 需要掌握多套工具 | 7个日常命令 | ⬇️ 学习曲线 |
| **工作流一致性** | 各语言流程不同 | 统一的工作流 | ⬆️ 开发效率 |
| **工具管理** | 分散安装和配置 | 一键搭建环境 | ⬇️ 配置复杂度 |
| **质量保证** | 手动执行检查 | 自动化钩子 | ⬆️ 代码质量 |
| **新手友好度** | 高门槛 | 即时上手 | ⬆️ 团队协作 |

## 🧪 质量保证

### 测试覆盖
- ✅ **基础命令测试**: 所有15个核心命令
- ✅ **智能检测测试**: 项目自动识别
- ✅ **工作流测试**: format、check、test、build流程
- ✅ **向后兼容测试**: 专用语言命令可用性
- ✅ **性能测试**: 无警告、零错误运行

### CI/CD流水线
```bash
make ci  # 完整CI流程：format → check → test → build
```

### 质量指标
- **零警告**: 所有Makefile执行无警告
- **零错误**: 命令执行无错误退出
- **完整覆盖**: 支持4种主流语言
- **高度自动化**: Git钩子自动执行质量检查

## 🤝 贡献指南

### 开发环境搭建
```bash
git clone https://github.com/scguoi/remote-ci.git
cd remote-ci
make setup              # 安装所有工具和钩子
make status             # 验证环境搭建
```

### 添加新语言支持
1. 在`makefiles/`中创建新的`.mk`文件
2. 实现标准接口：`install-tools-*`, `fmt-*`, `check-*`, `test-*`, `build-*`, `clean-*`
3. 更新`detection.mk`中的检测逻辑
4. 在`workflows.mk`中添加智能工作流支持
5. 运行`./makefile-tests/test_makefile.sh`验证功能

### 提交规范
项目使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```bash
feat: add Rust language support
fix: resolve TypeScript tool check issue
docs: update installation guide
refactor: optimize project detection logic
test: add integration tests for Python workflow
```

## 📊 项目统计

- **🧪 测试覆盖**: 60+个测试场景，100%通过率
- **📝 代码规模**: ~2500行Makefile代码
- **🎯 效率提升**: 统一的开发工作流
- **⚡ 技术栈**: 4种语言，1套工具链
- **🔧 工具集成**: 15+个质量检查工具

## 📚 相关文档

- **[Makefile-readme.md](./Makefile-readme.md)** - 完整技术文档 (英文版)
- **[Makefile-readme-zh.md](./Makefile-readme-zh.md)** - 完整技术文档 (中文版)
- **[CLAUDE.md](./CLAUDE.md)** - Claude Code开发指南

## ⚖️ 许可证

本项目采用 **MIT 许可证**。详情请查看 [LICENSE](./LICENSE) 文件。

---

## 🎉 享受统一的多语言开发体验！

**快速上手** → `make setup && make format && make check`
**完整流程** → `make ci`
**安全推送** → `make push`

如有问题或建议，欢迎提交 [Issue](https://github.com/scguoi/remote-ci/issues) 或 [Pull Request](https://github.com/scguoi/remote-ci/pulls)。