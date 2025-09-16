# =============================================================================
# 多语言CI/CD工具链 - 优化版主Makefile (仅15个核心命令)
# 从95个命令精简到15个核心命令，提供智能项目检测和自动化工作流
# =============================================================================

# Include core modules
include makefiles/core/detection.mk
include makefiles/core/workflows.mk

# Include original language modules (for internal calls)
include makefiles/go.mk
include makefiles/typescript.mk
include makefiles/java.mk
include makefiles/python.mk
include makefiles/git.mk
include makefiles/common.mk
include makefiles/comment-check.mk

# =============================================================================
# 核心命令声明
# =============================================================================
.PHONY: help setup format check test build dev push clean status info lint fix ci hooks enable-legacy

# =============================================================================
# 第一层：日常核心命令 (8个) - 你只需要记住这些！
# =============================================================================

# Default target - 智能帮助
.DEFAULT_GOAL := help
help: ## 📚 显示帮助信息和项目状态  
	@echo "$(BLUE)🚀 多语言CI/CD工具链 - 智能版$(RESET)"
	@echo "$(YELLOW)活跃项目:$(RESET) $(GREEN)$(ACTIVE_PROJECTS)$(RESET) | $(YELLOW)当前上下文:$(RESET) $(GREEN)$(CURRENT_CONTEXT)$(RESET)"
	@echo ""
	@echo "$(BLUE)📋 核心命令 (日常开发):$(RESET)"
	@echo "  $(GREEN)make setup$(RESET)     🛠️  一次性环境搭建 (工具+钩子+分支策略)"
	@echo "  $(GREEN)make format$(RESET)    ✨  格式化代码 (智能检测: $(ACTIVE_PROJECTS))"
	@echo "  $(GREEN)make check$(RESET)     🔍  质量检查 (智能检测: $(ACTIVE_PROJECTS))"  
	@echo "  $(GREEN)make test$(RESET)      🧪  运行测试 (智能检测: $(ACTIVE_PROJECTS))"
	@echo "  $(GREEN)make build$(RESET)     📦  构建项目 (智能检测: $(ACTIVE_PROJECTS))"
	@echo "  $(GREEN)make dev$(RESET)       🚀  启动开发服务器 (上下文: $(CURRENT_CONTEXT))"
	@echo "  $(GREEN)make push$(RESET)      📤  安全推送到远程 (预检查)"
	@echo "  $(GREEN)make clean$(RESET)     🧹  清理构建产物"
	@echo ""
	@echo "$(BLUE)🔧 专业命令:$(RESET)"
	@echo "  $(GREEN)make status$(RESET)    📊  显示详细项目状态"
	@echo "  $(GREEN)make info$(RESET)      ℹ️   显示工具和依赖信息"  
	@echo "  $(GREEN)make lint$(RESET)      🔧  运行代码检查 (check的别名)"
	@echo "  $(GREEN)make fix$(RESET)       🛠️  自动修复代码问题"
	@echo "  $(GREEN)make ci$(RESET)        🤖  完整CI流程 (format+check+test+build)"
	@echo ""
	@echo "$(BLUE)⚙️ 高级命令:$(RESET)"
	@echo "  $(GREEN)make hooks$(RESET)     ⚙️  Git钩子管理菜单"
	@echo "  $(GREEN)make enable-legacy$(RESET) 🔄  启用完整旧命令集 (向后兼容)"
	@echo ""
	@if [ "$(IS_MULTI_PROJECT)" = "true" ]; then \
		echo "$(YELLOW)💡 检测到多项目环境，所有命令将智能处理多个项目$(RESET)"; \
	else \
		echo "$(YELLOW)💡 单项目环境，可在子目录中使用 'make dev' 进行上下文切换$(RESET)"; \
	fi

# 核心工作流命令 - 直接调用智能实现
setup: smart_setup ## 🛠️ 一次性环境搭建 (工具+钩子+分支策略)

format: smart_format ## ✨ 智能代码格式化 (检测活跃项目)

check: smart_check ## 🔍 智能代码质量检查 (检测活跃项目)  

test: smart_test ## 🧪 智能测试运行 (检测活跃项目)

build: smart_build ## 📦 智能项目构建 (检测活跃项目)

dev: smart_dev ## 🚀 智能开发服务器 (根据上下文启动)

push: smart_push ## 📤 智能安全推送 (分支检查+质量检查)

clean: smart_clean ## 🧹 智能清理构建产物

# =============================================================================  
# 第二层：专业命令 (5个)
# =============================================================================

status: smart_status ## 📊 显示详细的项目状态

info: smart_info ## ℹ️ 显示工具和依赖信息  

lint: smart_check ## 🔧 运行代码检查 (check的别名)

fix: smart_fix ## 🛠️ 自动修复代码问题 (format + 部分lint修复)

ci: smart_ci ## 🤖 完整CI流程 (format + check + test + build)

# =============================================================================
# 第三层：高级命令 (2个) 
# =============================================================================

hooks: ## ⚙️ Git钩子管理菜单
	@echo "$(BLUE)⚙️ Git钩子管理$(RESET)"
	@echo ""
	@echo "$(GREEN)安装钩子:$(RESET)"
	@echo "  make hooks-install       📌 安装所有钩子 (推荐)"
	@echo "  make hooks-install-basic 📋 安装基本钩子 (轻量)"
	@echo "  make hooks-fmt           ✨ 仅格式化钩子"
	@echo "  make hooks-commit-msg    💬 仅提交消息钩子"
	@echo ""
	@echo "$(RED)卸载钩子:$(RESET)"
	@echo "  make hooks-uninstall     ❌ 卸载所有钩子"
	@echo ""
	@echo "$(YELLOW)当前钩子状态:$(RESET)"
	@ls -la .git/hooks/ | grep -E "(pre-commit|commit-msg|pre-push)" | head -3

enable-legacy: ## 🔄 启用完整的旧命令集 (向后兼容)
	@echo "$(YELLOW)🔄 启用旧命令集...$(RESET)"
	@if [ ! -f "makefiles/legacy/enabled" ]; then \
		echo "# Legacy commands enabled" > makefiles/legacy/enabled; \
		echo "$(GREEN)✅ 旧命令集已启用$(RESET)"; \
		echo ""; \
		echo "$(BLUE)现在你可以使用所有原始命令，例如:$(RESET)"; \
		echo "  make fmt-go fmt-java fmt-python fmt-typescript"; \
		echo "  make check-go check-java check-python check-typescript"; \
		echo "  make install-tools-go install-tools-java ..."; \
		echo ""; \
		echo "$(YELLOW)注意: 建议优先使用新的智能命令以获得更好体验$(RESET)"; \
	else \
		echo "$(GREEN)✅ 旧命令集已经启用$(RESET)"; \
	fi

# =============================================================================
# 向后兼容：条件包含旧命令
# =============================================================================
-include makefiles/legacy/enabled
ifneq (,$(wildcard makefiles/legacy/enabled))
    # 如果启用了legacy模式，这里可以包含额外的旧命令定义
    # 但当前版本中，旧命令通过原始模块文件直接可用
endif

# =============================================================================
# 隐藏的工具命令 (用于调试和测试)
# =============================================================================
_debug: ## 🔍 [调试] 测试项目检测和Makefile状态
	@echo "$(YELLOW)项目检测测试:$(RESET)"
	@echo "ACTIVE_PROJECTS: '$(ACTIVE_PROJECTS)'"
	@echo "CURRENT_CONTEXT: '$(CURRENT_CONTEXT)'"
	@echo "PROJECT_COUNT: $(PROJECT_COUNT)"
	@echo "IS_MULTI_PROJECT: $(IS_MULTI_PROJECT)"
	$(call show_project_status)
	@echo ""
	@echo "$(BLUE)当前Makefile状态:$(RESET)"
	@echo "包含的模块: detection.mk workflows.mk + 原始语言模块"