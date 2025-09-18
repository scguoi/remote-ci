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
		if [ -n "$(LOCALCI_CONFIG)" ] && [ -f "$(LOCALCI_CONFIG)" ]; then \
			scripts/parse_localci.sh langs $(LOCALCI_CONFIG); \
		else \
			PROJECTS=""; \
			[ -f "demo-apps/backends/go/go.mod" ] && [ -d "demo-apps/backends/go/cmd" ] && PROJECTS="$$PROJECTS go"; \
			[ -f "demo-apps/backends/java/pom.xml" ] && [ -d "demo-apps/backends/java/user-web" ] && PROJECTS="$$PROJECTS java"; \
			[ -f "demo-apps/backends/python/main.py" ] && [ -f "demo-apps/backends/python/requirements.txt" ] && PROJECTS="$$PROJECTS python"; \
			[ -f "demo-apps/frontends/ts/package.json" ] && [ -f "demo-apps/frontends/ts/tsconfig.json" ] && PROJECTS="$$PROJECTS typescript"; \
			echo $$PROJECTS | sed 's/^ //'; \
		fi \
	)
endef

# Detect current working directory context (for intelligent dev commands)
define detect_current_context
	$(shell \
		CURRENT_DIR=$$(basename "$(PWD)"); \
		if [ -f "./go.mod" ] || [ "$$CURRENT_DIR" = "go" ]; then echo "go"; \
		elif [ -f "./pom.xml" ] || [ "$$CURRENT_DIR" = "java" ]; then echo "java"; \
		elif [ -f "./main.py" ] && [ -f "./requirements.txt" ] || [ "$$CURRENT_DIR" = "python" ]; then echo "python"; \
		elif [ -f "./package.json" ] && [ -f "./tsconfig.json" ] || [ "$$CURRENT_DIR" = "ts" ]; then echo "typescript"; \
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

# Helper functions to get directories from config
define get_language_dirs
	$(shell \
		if [ -n "$(LOCALCI_CONFIG)" ] && [ -f "$(LOCALCI_CONFIG)" ]; then \
			scripts/parse_localci.sh enabled $(1) $(LOCALCI_CONFIG) | cut -d'|' -f2; \
		else \
			case "$(1)" in \
				go) echo "demo-apps/backends/go" ;; \
				java) echo "demo-apps/backends/java" ;; \
				python) echo "demo-apps/backends/python" ;; \
				typescript) echo "demo-apps/frontends/ts" ;; \
			esac; \
		fi \
	)
endef

# Get first directory for a language (for legacy single-dir commands)
define get_first_language_dir
	$(shell \
		dirs="$(call get_language_dirs,$(1))"; \
		echo $$dirs | cut -d' ' -f1 \
	)
endef

# Check if this is a multi-project environment
IS_MULTI_PROJECT := $(shell [ "$(PROJECT_COUNT)" -gt 1 ] && echo "true" || echo "false")

# Project status display function
define show_project_status
	@echo "$(BLUE)Detected Active Projects:$(RESET)"
	@if echo "$(ACTIVE_PROJECTS)" | grep -q "go"; then \
		go_dir="$(call get_first_language_dir,go)"; \
		if [ -d "$$go_dir" ] && [ -f "$$go_dir/go.mod" ]; then echo "  $(GREEN)✓ Go Backend$(RESET)         ($$go_dir)"; else echo "  $(RED)✗ Go Backend$(RESET)         ($$go_dir)"; fi; \
	fi
	@if echo "$(ACTIVE_PROJECTS)" | grep -q "typescript"; then \
		ts_dir="$(call get_first_language_dir,typescript)"; \
		if [ -d "$$ts_dir" ] && [ -f "$$ts_dir/package.json" ]; then echo "  $(GREEN)✓ TypeScript Frontend$(RESET) ($$ts_dir)"; else echo "  $(RED)✗ TypeScript Frontend$(RESET) ($$ts_dir)"; fi; \
	fi
	@if echo "$(ACTIVE_PROJECTS)" | grep -q "java"; then \
		java_dir="$(call get_first_language_dir,java)"; \
		if [ -d "$$java_dir" ] && [ -f "$$java_dir/pom.xml" ]; then echo "  $(GREEN)✓ Java Backend$(RESET)        ($$java_dir)"; else echo "  $(RED)✗ Java Backend$(RESET)        ($$java_dir)"; fi; \
	fi
	@if echo "$(ACTIVE_PROJECTS)" | grep -q "python"; then \
		python_dir="$(call get_first_language_dir,python)"; \
		if [ -d "$$python_dir" ] && [ -f "$$python_dir/main.py" ]; then echo "  $(GREEN)✓ Python Backend$(RESET)      ($$python_dir)"; else echo "  $(RED)✗ Python Backend$(RESET)      ($$python_dir)"; fi; \
	fi
	@echo "$(BLUE)Current Context:$(RESET) $(YELLOW)$(CURRENT_CONTEXT)$(RESET)"
	@echo "$(BLUE)Intelligent Operation Target:$(RESET) $(GREEN)$(ACTIVE_PROJECTS)$(RESET)"
endef

# Project detection variables and function definitions complete
# _debug target defined in main Makefile to avoid duplicate definition warnings
