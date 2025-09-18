# =============================================================================
# Intelligent Project Detection Mechanism - Core Detection Module
# =============================================================================

# Color definitions for output
RED := \033[31m
GREEN := \033[32m
YELLOW := \033[33m
BLUE := \033[34m
RESET := \033[0m

# LocalCI config path (local override, then default template)
LOCALCI_CONFIG := $(shell if [ -f .localci.toml ]; then echo .localci.toml; elif [ -f makefiles/localci.toml ]; then echo makefiles/localci.toml; fi)

# Detect active project types (based on actual file existence)
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

# Detect current working directory context (for intelligent dev commands)
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

# Intelligent variables (use localci config if exists)
ifeq ($(strip $(LOCALCI_CONFIG)),)
  ACTIVE_PROJECTS := $(detect_active_projects)
else
  ACTIVE_PROJECTS := $(shell scripts/parse_localci.sh langs $(LOCALCI_CONFIG))
endif
CURRENT_CONTEXT := $(detect_current_context)
PROJECT_COUNT := $(shell echo $(ACTIVE_PROJECTS) | wc -w | tr -d ' ')

# Check if this is a multi-project environment
IS_MULTI_PROJECT := $(shell [ "$(PROJECT_COUNT)" -gt 1 ] && echo "true" || echo "false")

# Project status display function
define show_project_status
	@echo "$(BLUE)Detected Active Projects:$(RESET)"
	@if [ -d "backend-go" ] && [ -f "backend-go/go.mod" ]; then echo "  $(GREEN)✓ Go Backend$(RESET)         (backend-go/)"; else echo "  $(RED)✗ Go Backend$(RESET)         (backend-go/)"; fi
	@if [ -d "frontend-ts" ] && [ -f "frontend-ts/package.json" ]; then echo "  $(GREEN)✓ TypeScript Frontend$(RESET) (frontend-ts/)"; else echo "  $(RED)✗ TypeScript Frontend$(RESET) (frontend-ts/)"; fi
	@if [ -d "backend-java" ] && [ -f "backend-java/pom.xml" ]; then echo "  $(GREEN)✓ Java Backend$(RESET)        (backend-java/)"; else echo "  $(RED)✗ Java Backend$(RESET)        (backend-java/)"; fi
	@if [ -d "backend-python" ] && [ -f "backend-python/main.py" ]; then echo "  $(GREEN)✓ Python Backend$(RESET)      (backend-python/)"; else echo "  $(RED)✗ Python Backend$(RESET)      (backend-python/)"; fi
	@echo "$(BLUE)Current Context:$(RESET) $(YELLOW)$(CURRENT_CONTEXT)$(RESET)"
	@echo "$(BLUE)Intelligent Operation Target:$(RESET) $(GREEN)$(ACTIVE_PROJECTS)$(RESET)"
endef

# Project detection variables and function definitions complete
# _debug target defined in main Makefile to avoid duplicate definition warnings
