# =============================================================================
# 智能项目检测机制 - Core Detection Module
# =============================================================================

# Color definitions for output
RED := \033[31m
GREEN := \033[32m
YELLOW := \033[33m
BLUE := \033[34m
RESET := \033[0m

# 检测活跃的项目类型 (基于实际文件存在)
define detect_active_projects
	$(shell \
		PROJECTS=""; \
		[ -f "backend-go/go.mod" ] && [ -d "backend-go/cmd" ] && PROJECTS="$$PROJECTS go"; \
		[ -f "backend-java/pom.xml" ] && [ -d "backend-java/user-web" ] && PROJECTS="$$PROJECTS java"; \
		[ -f "backend-python/main.py" ] && [ -f "backend-python/requirements.txt" ] && PROJECTS="$$PROJECTS python"; \
		[ -f "frontend-ts/package.json" ] && [ -f "frontend-ts/tsconfig.json" ] && PROJECTS="$$PROJECTS typescript"; \
		echo $$PROJECTS | sed 's/^ //' \
	)
endef

# 检测当前工作目录上下文 (用于智能dev命令)
define detect_current_context
	$(shell \
		CURRENT_DIR=$$(basename "$(PWD)"); \
		if [ -f "./go.mod" ] || [ "$$CURRENT_DIR" = "backend-go" ]; then echo "go"; \
		elif [ -f "./pom.xml" ] || [ "$$CURRENT_DIR" = "backend-java" ]; then echo "java"; \
		elif [ -f "./main.py" ] && [ -f "./requirements.txt" ] || [ "$$CURRENT_DIR" = "backend-python" ]; then echo "python"; \
		elif [ -f "./package.json" ] && [ -f "./tsconfig.json" ] || [ "$$CURRENT_DIR" = "frontend-ts" ]; then echo "typescript"; \
		else echo "all"; fi \
	)
endef

# 智能变量
ACTIVE_PROJECTS := $(detect_active_projects)
CURRENT_CONTEXT := $(detect_current_context)
PROJECT_COUNT := $(shell echo $(ACTIVE_PROJECTS) | wc -w | tr -d ' ')

# 检查是否是多项目环境
IS_MULTI_PROJECT := $(shell [ "$(PROJECT_COUNT)" -gt 1 ] && echo "true" || echo "false")

# 项目状态显示函数
define show_project_status
	@echo "$(BLUE)检测到的活跃项目:$(RESET)"
	@if [ -d "backend-go" ] && [ -f "backend-go/go.mod" ]; then echo "  $(GREEN)✓ Go Backend$(RESET)         (backend-go/)"; else echo "  $(RED)✗ Go Backend$(RESET)         (backend-go/)"; fi
	@if [ -d "frontend-ts" ] && [ -f "frontend-ts/package.json" ]; then echo "  $(GREEN)✓ TypeScript Frontend$(RESET) (frontend-ts/)"; else echo "  $(RED)✗ TypeScript Frontend$(RESET) (frontend-ts/)"; fi
	@if [ -d "backend-java" ] && [ -f "backend-java/pom.xml" ]; then echo "  $(GREEN)✓ Java Backend$(RESET)        (backend-java/)"; else echo "  $(RED)✗ Java Backend$(RESET)        (backend-java/)"; fi
	@if [ -d "backend-python" ] && [ -f "backend-python/main.py" ]; then echo "  $(GREEN)✓ Python Backend$(RESET)      (backend-python/)"; else echo "  $(RED)✗ Python Backend$(RESET)      (backend-python/)"; fi
	@echo "$(BLUE)当前上下文:$(RESET) $(YELLOW)$(CURRENT_CONTEXT)$(RESET)"
	@echo "$(BLUE)智能操作目标:$(RESET) $(GREEN)$(ACTIVE_PROJECTS)$(RESET)"
endef

# 项目检测变量和函数定义完成
# _debug 目标在主Makefile中定义，避免重复定义警告
