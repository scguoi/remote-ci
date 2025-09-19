# 🚀 Intelligent Multi-Language CI/CD Toolchain

[![Unified Workflow](https://img.shields.io/badge/workflow-unified-blue)](#core-features)
[![Multi-Language Support](https://img.shields.io/badge/languages-4-orange)](#supported-languages)
[![Smart Commands](https://img.shields.io/badge/commands-15-green)](#complete-command-reference)
[![TypeScript Global Tools](https://img.shields.io/badge/TypeScript-global--tools-red)](#supported-languages)

> **Unified multi-language development workflow supporting Go, Java, Python, TypeScript with intelligent CI/CD toolchain**

## 🎯 Project Overview

This is an **intelligent multi-language CI/CD toolchain** that provides complete development workflow support for Go, Java, Python, and TypeScript projects through a unified Makefile system.

### 🎯 Core Design Philosophy

**Intelligence**: Automatic project type detection without manual configuration
**Unification**: One command set adapts to all language development processes
**Simplicity**: 15 core commands cover all development scenarios

### ✨ Core Features

- **🧠 Smart Detection**: Project type identification based on file patterns and configuration
- **🎯 Concise Commands**: 15 core commands covering all development scenarios
- **🔄 Perfect Compatibility**: All specialized language commands remain available
- **⚡ Zero Learning Cost**: Only need to remember 7 daily commands
- **🛠️ Unified Workflow**: One command set adapts to multiple languages
- **🌐 TypeScript Global Tools**: Avoid project dependency conflicts
- **📄 Flexible Configuration**: Support TOML-driven project management

## 🏗️ Supported Languages & Tech Stack

| Language | Main Frameworks | Development Toolchain | Quality Check Tools | Special Config |
|----------|-----------------|----------------------|-------------------|----------------|
| **Go** | Gin, GORM, Echo | gofmt, goimports, gofumpt | staticcheck, golangci-lint | - |
| **Java** | Spring Boot, Maven | Spotless, Checkstyle | PMD, SpotBugs | - |
| **Python** | FastAPI, Flask, Django | black, isort | flake8, mypy, pylint | - |
| **TypeScript** | React, Vue, Node.js | prettier, eslint | tsc type checking | ✅ Global tool installation |

### 🛠️ Quality Toolchain

- **Go**: `gofmt` → `goimports` → `gofumpt` → `golines` → `staticcheck` → `golangci-lint`
- **Java**: `Spotless` → `Checkstyle` → `PMD` → `SpotBugs`
- **Python**: `black` → `isort` → `flake8` → `mypy` → `pylint`
- **TypeScript**: `prettier` → `eslint` → `tsc` (globally installed, avoiding dependency conflicts)

## 🚀 Quick Start

### Local Development Environment

```bash
# 1. One-time environment setup
make setup    # Install all language tools + configure Git hooks

# 2. Daily development workflow
make format   # ✨ Smart format all language code
make check    # 🔍 Smart quality check all projects
make test     # 🧪 Run all project tests
make build    # 📦 Build all projects
make push     # 📤 Safe push (automatic pre-check)
```

That simple! One command set adapts to all languages.

## 📋 Complete Command Reference

### 🏆 Daily Core Commands (7) - Zero Learning Cost

| Command | Function | Smart Features |
|---------|----------|----------------|
| `make setup` | Environment setup | One-time install all language tools + Git hooks |
| `make format` | Code formatting | Auto-detect and format all 4 languages |
| `make check` | Quality check | Auto-run quality checks for all 4 languages |
| `make test` | Run tests | Auto-run Go/Java/Python tests |
| `make build` | Project build | Smart build Go and Java projects |
| `make push` | Safe push | Pre-check + branch validation + auto push |
| `make clean` | Clean build artifacts | Clean build caches for all languages |

### 🔧 Professional Commands (5)

| Command | Function |
|---------|----------|
| `make status` | Display project detection status and statistics |
| `make info` | Display installation status for all language tools |
| `make lint` | Code check (alias for check command) |
| `make fix` | Auto-fix code issues |
| `make ci` | Complete CI pipeline (format+check+test+build) |

### ⚙️ Advanced Commands (3)

| Command | Function |
|---------|----------|
| `make hooks` | Git hook management menu |
| `make enable-legacy` | Enable complete specialized language commands |
| `make _debug` | Debug project detection mechanism |

## 🧠 Smart Features Showcase

### 🧪 Automatic Project Detection
```bash
$ make status
Detected active projects: go java python typescript
Smart detection mechanism: Based on file pattern recognition
Workflow mode: Unified command adaptation
Current context: Multi-language development environment

Toolchain status:
  ✅ Go toolchain complete
  ✅ Java Maven configuration normal
  ✅ Python virtual environment ready
  ✅ TypeScript global tools available
```

### Local Service Execution
```bash
# Run native commands in respective project directories
cd your-go-project && go run main.go              # → Go service
cd your-java-project && mvn spring-boot:run       # → Spring Boot app
cd your-python-project && python main.py          # → Python API service
cd your-ts-project && npm run dev                 # → TypeScript dev server
```

### Smart Batch Operations
```bash
# One command, process all languages
make format  # Simultaneously format Go, Java, Python, TypeScript code
make check   # Simultaneously check code quality for all languages
make test    # Simultaneously run Go, Java, Python tests
```

## 📁 Toolchain Architecture

```
remote-ci/
├── 🎯 Makefile                     # 15 smart core commands
├── 📂 makefiles/
│   ├── 🧠 core/
│   │   ├── detection.mk            # Smart project detection engine
│   │   └── workflows.mk            # Core workflow implementation
│   ├── 🐹 go.mk                    # Go language support (7 unified commands)
│   ├── ☕ java.mk                  # Java/Maven support (7 unified commands)
│   ├── 🐍 python.mk               # Python support (7 unified commands)
│   ├── 📘 typescript.mk           # TypeScript/Node support (7 unified commands)
│   └── 🌿 git.mk                   # Git hooks and branch management (21 commands)
├── 📜 scripts/
│   └── parse_localci.sh           # Configuration parsing script
├── 🧪 makefile-tests/
│   ├── test_makefile.sh          # Comprehensive test script
│   └── quick_test.sh             # Quick test script
├── .localci.toml                  # Project configuration file (optional)
└── 📚 docs/
    ├── Makefile-readme.md         # Detailed technical documentation (English)
    └── Makefile-readme-zh.md      # Detailed technical documentation (Chinese)
```

### 🎯 Design Principles

- **Modularity**: Independent .mk files for each language
- **Standardization**: Unified 7-command interface
- **Extensibility**: Easy to add new language support
- **Intelligence**: Automatic detection and adaptation

## 🔧 Advanced Features

### Git Hook Automation
```bash
make hooks              # Display hook management menu
make hooks-install      # Install complete hooks (recommended)
make hooks-install-basic # Install lightweight hooks (faster)
```

Automatically enabled hooks:
- **pre-commit**: Auto-format + code quality check
- **commit-msg**: Verify commit message format (Conventional Commits)
- **pre-push**: Verify branch naming conventions

### Backward Compatibility
```bash
make enable-legacy  # Enable complete specialized language commands

# Then you can use all original commands:
make fmt-go                    # Go formatting
make check-java               # Java quality check
make test-python              # Python testing
make install-tools-typescript # TypeScript tool installation
# ... all specialized commands are preserved
```

### TypeScript Global Tools Advantages
```bash
# Global installation, avoiding project dependency conflicts
npm install -g typescript prettier eslint

# Direct usage, no npx prefix needed
prettier --write "**/*.{ts,tsx,js,jsx}"
eslint "**/*.{ts,tsx,js,jsx}"
tsc --noEmit
```

### Debugging and Troubleshooting
```bash
make _debug          # Display project detection debug info
make info           # View all tool installation status
make check-tools-go # Check specific language tool status
```

## 📈 Toolchain Advantages

| Feature | Traditional Approach | Smart Toolchain | Advantage |
|---------|---------------------|-----------------|-----------|
| **Command Complexity** | Different commands for each language | Unified 15 commands | ⬇️ Cognitive load |
| **Learning Cost** | Need to master multiple toolsets | 7 daily commands | ⬇️ Learning curve |
| **Workflow Consistency** | Different processes for each language | Unified workflow | ⬆️ Development efficiency |
| **Tool Management** | Scattered installation and config | One-click environment setup | ⬇️ Configuration complexity |
| **Quality Assurance** | Manual execution of checks | Automated hooks | ⬆️ Code quality |
| **Newcomer Friendliness** | High barrier to entry | Instant onboarding | ⬆️ Team collaboration |

## 🧪 Quality Assurance

### Test Coverage
- ✅ **Basic Command Tests**: All 15 core commands
- ✅ **Smart Detection Tests**: Automatic project identification
- ✅ **Workflow Tests**: format, check, test, build processes
- ✅ **Backward Compatibility Tests**: Specialized language command availability
- ✅ **Performance Tests**: Warning-free, error-free execution

### CI/CD Pipeline
```bash
make ci  # Complete CI process: format → check → test → build
```

### Quality Metrics
- **Zero Warnings**: All Makefile executions without warnings
- **Zero Errors**: Command executions without error exits
- **Complete Coverage**: Support for 4 mainstream languages
- **High Automation**: Git hooks automatically execute quality checks

## 🤝 Contributing Guide

### Development Environment Setup
```bash
git clone https://github.com/scguoi/remote-ci.git
cd remote-ci
make setup              # Install all tools and hooks
make status             # Verify environment setup
```

### Adding New Language Support
1. Create new `.mk` file in `makefiles/`
2. Implement standard interface: `install-tools-*`, `fmt-*`, `check-*`, `test-*`, `build-*`, `clean-*`
3. Update detection logic in `detection.mk`
4. Add smart workflow support in `workflows.mk`
5. Run `./makefile-tests/test_makefile.sh` to verify functionality

### Commit Conventions
Project uses [Conventional Commits](https://www.conventionalcommits.org/) specification:

```bash
feat: add Rust language support
fix: resolve TypeScript tool check issue
docs: update installation guide
refactor: optimize project detection logic
test: add integration tests for Python workflow
```

## 📊 Project Statistics

- **🧪 Test Coverage**: 60+ test scenarios, 100% pass rate
- **📝 Code Scale**: ~2500 lines of Makefile code
- **🎯 Efficiency Gain**: Unified development workflow
- **⚡ Tech Stack**: 4 languages, 1 toolchain
- **🔧 Tool Integration**: 15+ quality check tools

## 📚 Related Documentation

- **[Makefile-readme.md](./Makefile-readme.md)** - Complete technical documentation (English)
- **[Makefile-readme-zh.md](./Makefile-readme-zh.md)** - Complete technical documentation (Chinese)
- **[CLAUDE.md](./CLAUDE.md)** - Claude Code development guide

## ⚖️ License

This project is licensed under the **MIT License**. See the [LICENSE](./LICENSE) file for details.

---

## 🎉 Enjoy the unified multi-language development experience!

**Quick Start** → `make setup && make format && make check`
**Complete Process** → `make ci`
**Safe Push** → `make push`

For questions or suggestions, feel free to submit an [Issue](https://github.com/scguoi/remote-ci/issues) or [Pull Request](https://github.com/scguoi/remote-ci/pulls).