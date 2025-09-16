# =============================================================================
# 智能工作流核心实现 - Core Workflows Module  
# =============================================================================

# Include detection mechanism
include makefiles/core/detection.mk

# =============================================================================
# 智能设置 - setup
# =============================================================================
smart_setup: ## 🛠️ 智能环境设置 (工具+钩子+分支策略)
	@echo "$(BLUE)🛠️  智能环境设置开始...$(RESET)"
	$(call show_project_status)
	@echo ""
	@echo "$(YELLOW)正在安装开发工具...$(RESET)"
	@$(MAKE) --no-print-directory smart_install_tools
	@echo ""
	@echo "$(YELLOW)正在配置Git钩子...$(RESET)"
	@$(MAKE) --no-print-directory hooks-install
	@echo ""
	@echo "$(YELLOW)正在设置分支策略...$(RESET)"
	@$(MAKE) --no-print-directory branch-setup
	@echo ""
	@echo "$(GREEN)✅ 智能环境设置完成!$(RESET)"
	@echo "$(BLUE)可用的核心命令:$(RESET) setup format check test build dev push clean"

# 智能工具安装
smart_install_tools:
	@echo "$(YELLOW)为活跃项目安装工具: $(ACTIVE_PROJECTS)$(RESET)"
	@for project in $(ACTIVE_PROJECTS); do \
		case $$project in \
			go) echo "  - 安装Go工具..." && $(MAKE) --no-print-directory install-tools-go ;; \
			java) echo "  - 安装Java工具..." && $(MAKE) --no-print-directory install-tools-java ;; \
			python) echo "  - 安装Python工具..." && $(MAKE) --no-print-directory install-tools-python ;; \
			typescript) echo "  - 安装TypeScript工具..." && $(MAKE) --no-print-directory install-tools-typescript ;; \
		esac; \
	done

# =============================================================================
# 智能格式化 - format
# =============================================================================
smart_format: ## ✨ 智能代码格式化 (检测活跃项目)
	@if [ -z "$(ACTIVE_PROJECTS)" ]; then \
		echo "$(RED)❌ 未检测到任何活跃项目$(RESET)"; \
		exit 1; \
	fi
	@echo "$(BLUE)✨ 智能格式化: $(GREEN)$(ACTIVE_PROJECTS)$(RESET)"
	@for project in $(ACTIVE_PROJECTS); do \
		case $$project in \
			go) echo "  - 格式化Go代码..." && $(MAKE) --no-print-directory fmt-go ;; \
			java) echo "  - 格式化Java代码..." && $(MAKE) --no-print-directory fmt-java ;; \
			python) echo "  - 格式化Python代码..." && $(MAKE) --no-print-directory fmt-python ;; \
			typescript) echo "  - 格式化TypeScript代码..." && $(MAKE) --no-print-directory fmt-typescript ;; \
		esac; \
	done
	@echo "$(GREEN)✅ 格式化完成: $(ACTIVE_PROJECTS)$(RESET)"

# =============================================================================
# 智能质量检查 - check
# =============================================================================
smart_check: ## 🔍 智能代码质量检查 (检测活跃项目)
	@if [ -z "$(ACTIVE_PROJECTS)" ]; then \
		echo "$(RED)❌ 未检测到任何活跃项目$(RESET)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🔍 智能质量检查: $(GREEN)$(ACTIVE_PROJECTS)$(RESET)"
	@for project in $(ACTIVE_PROJECTS); do \
		case $$project in \
			go) echo "  - 检查Go代码..." && $(MAKE) --no-print-directory check-go ;; \
			java) echo "  - 检查Java代码..." && $(MAKE) --no-print-directory check-java ;; \
			python) echo "  - 检查Python代码..." && $(MAKE) --no-print-directory check-python ;; \
			typescript) echo "  - 检查TypeScript代码..." && $(MAKE) --no-print-directory check-typescript ;; \
		esac; \
	done
	@echo "$(YELLOW)检查注释语言规范...$(RESET)"
	@$(MAKE) --no-print-directory check-comments
	@echo "$(GREEN)✅ 质量检查完成: $(ACTIVE_PROJECTS)$(RESET)"

# =============================================================================
# 智能测试 - test
# =============================================================================
smart_test: ## 🧪 智能测试运行 (检测活跃项目)
	@if [ -z "$(ACTIVE_PROJECTS)" ]; then \
		echo "$(RED)❌ 未检测到任何活跃项目$(RESET)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🧪 智能测试: $(GREEN)$(ACTIVE_PROJECTS)$(RESET)"
	@for project in $(ACTIVE_PROJECTS); do \
		case $$project in \
			go) echo "  - 运行Go测试..." && $(MAKE) --no-print-directory test-go ;; \
			java) echo "  - 运行Java测试..." && $(MAKE) --no-print-directory test-java ;; \
			python) echo "  - 运行Python测试..." && $(MAKE) --no-print-directory test-python ;; \
			typescript) echo "  - 跳过TypeScript测试 (暂未配置)" ;; \
		esac; \
	done
	@echo "$(GREEN)✅ 测试完成: $(ACTIVE_PROJECTS)$(RESET)"

# =============================================================================
# 智能构建 - build
# =============================================================================
smart_build: ## 📦 智能项目构建 (检测活跃项目)
	@if [ -z "$(ACTIVE_PROJECTS)" ]; then \
		echo "$(RED)❌ 未检测到任何活跃项目$(RESET)"; \
		exit 1; \
	fi
	@echo "$(BLUE)📦 智能构建: $(GREEN)$(ACTIVE_PROJECTS)$(RESET)"
	@for project in $(ACTIVE_PROJECTS); do \
		case $$project in \
			go) echo "  - 构建Go项目..." && $(MAKE) --no-print-directory build-go ;; \
			java) echo "  - 构建Java项目..." && $(MAKE) --no-print-directory build-java ;; \
			python) echo "  - Python无需构建 (解释执行)" ;; \
			typescript) echo "  - 构建TypeScript项目..." && cd frontend-ts && npm run build ;; \
		esac; \
	done
	@echo "$(GREEN)✅ 构建完成: $(ACTIVE_PROJECTS)$(RESET)"

# =============================================================================
# 智能开发服务器 - dev
# =============================================================================
smart_dev: ## 🚀 智能开发服务器 (根据上下文启动)
	@echo "$(BLUE)🚀 智能开发服务器启动$(RESET)"
	@echo "$(YELLOW)当前上下文: $(CURRENT_CONTEXT)$(RESET)"
	@case $(CURRENT_CONTEXT) in \
		go) echo "  - 启动Go服务..." && cd backend-go && go run cmd/main.go ;; \
		java) echo "  - 启动Java Spring Boot..." && cd backend-java && mvn spring-boot:run ;; \
		python) echo "  - 启动Python FastAPI..." && cd backend-python && python main.py ;; \
		typescript) echo "  - 启动TypeScript开发服务器..." && cd frontend-ts && npm run dev ;; \
		all) echo "$(YELLOW)请在具体项目目录中运行 'make dev'，或指定项目:$(RESET)"; \
			echo "  make dev-go       - 启动Go服务"; \
			echo "  make dev-java     - 启动Java服务"; \
			echo "  make dev-python   - 启动Python服务"; \
			echo "  make dev-ts       - 启动TypeScript开发服务器"; \
			;; \
	esac

# 特定项目的dev命令 (兼容性)
dev-go:
	@cd backend-go && go run cmd/main.go

dev-java:  
	@cd backend-java && mvn spring-boot:run

dev-python:
	@cd backend-python && python main.py

dev-ts:
	@cd frontend-ts && npm run dev

# =============================================================================
# 智能推送 - push
# =============================================================================
smart_push: ## 📤 智能安全推送 (分支检查+质量检查)
	@echo "$(BLUE)📤 智能安全推送$(RESET)"
	@echo "$(YELLOW)检查分支命名规范...$(RESET)"
	@$(MAKE) --no-print-directory check-branch
	@echo "$(YELLOW)运行预推送质量检查...$(RESET)"
	@$(MAKE) --no-print-directory smart_format
	@$(MAKE) --no-print-directory smart_check
	@echo "$(YELLOW)推送到远程仓库...$(RESET)"
	@$(MAKE) --no-print-directory safe-push
	@echo "$(GREEN)✅ 安全推送完成$(RESET)"

# =============================================================================
# 智能清理 - clean
# =============================================================================
smart_clean: ## 🧹 智能清理构建产物
	@echo "$(BLUE)🧹 智能清理: $(GREEN)$(ACTIVE_PROJECTS)$(RESET)"
	@for project in $(ACTIVE_PROJECTS); do \
		case $$project in \
			go) echo "  - 清理Go构建产物..." && \
				if [ -d "backend-go" ]; then cd backend-go && go clean && rm -f bin/* || true; else echo "    Go目录不存在"; fi ;; \
			java) echo "  - 清理Java构建产物..." && \
				if [ -d "backend-java" ]; then $(MAKE) --no-print-directory clean-java; else echo "    Java目录不存在"; fi ;; \
			python) echo "  - 清理Python缓存..." && \
				if [ -d "backend-python" ]; then find backend-python -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true; else echo "    Python目录不存在"; fi ;; \
			typescript) echo "  - 清理TypeScript构建产物..." && \
				if [ -d "frontend-ts" ]; then cd frontend-ts && rm -rf dist node_modules/.cache || true; else echo "    TypeScript目录不存在"; fi ;; \
		esac; \
	done
	@echo "$(GREEN)✅ 清理完成: $(ACTIVE_PROJECTS)$(RESET)"

# =============================================================================
# 智能CI流程 - ci
# =============================================================================
smart_ci: ## 🤖 完整CI流程 (format + check + test + build)
	@echo "$(BLUE)🤖 完整CI流程开始$(RESET)"
	@$(MAKE) --no-print-directory smart_format
	@$(MAKE) --no-print-directory smart_check  
	@$(MAKE) --no-print-directory smart_test
	@$(MAKE) --no-print-directory smart_build
	@echo "$(GREEN)✅ CI流程完成$(RESET)"

# =============================================================================
# 智能修复 - fix  
# =============================================================================
smart_fix: ## 🛠️ 智能代码修复 (格式化 + 部分自动修复)
	@echo "$(BLUE)🛠️ 智能代码修复$(RESET)"
	@$(MAKE) --no-print-directory smart_format
	@echo "$(GREEN)✅ 自动修复完成 (主要为格式化)$(RESET)"

# =============================================================================
# 工具函数
# =============================================================================
smart_status: ## 📊 显示详细的项目状态
	@echo "$(BLUE)📊 项目状态详情$(RESET)"
	$(call show_project_status)
	@echo ""
	@echo "$(BLUE)活跃项目数量:$(RESET) $(PROJECT_COUNT)"
	@echo "$(BLUE)多项目环境:$(RESET) $(IS_MULTI_PROJECT)"

smart_info: ## ℹ️ 显示工具和依赖信息
	@echo "$(BLUE)ℹ️  工具和依赖信息$(RESET)"
	@$(MAKE) --no-print-directory smart_status
	@echo ""
	@for project in $(ACTIVE_PROJECTS); do \
		case $$project in \
			go) echo "$(YELLOW)Go工具状态:$(RESET)" && $(MAKE) --no-print-directory check-tools-go ;; \
			java) echo "$(YELLOW)Java工具状态:$(RESET)" && $(MAKE) --no-print-directory check-tools-java ;; \
			python) echo "$(YELLOW)Python工具状态:$(RESET)" && $(MAKE) --no-print-directory check-tools-python ;; \
			typescript) echo "$(YELLOW)TypeScript工具状态:$(RESET)" && $(MAKE) --no-print-directory check-tools-typescript ;; \
		esac; \
		echo ""; \
	done