# =============================================================================
# TypeScript Language Support - Makefile Module
# =============================================================================

# TypeScript project variables - use dynamic directories from config
NPM := npm
PRETTIER := prettier
ESLINT := eslint
TSC := typescript

# Get all TypeScript directories from config - use shell directly to avoid function call issues
TS_DIRS := $(shell \
	if [ -n "$(LOCALCI_CONFIG)" ] && [ -f "$(LOCALCI_CONFIG)" ]; then \
		scripts/parse_localci.sh enabled typescript $(LOCALCI_CONFIG) | cut -d'|' -f2 | tr '\n' ' '; \
	else \
		echo "demo-apps/frontends/ts"; \
	fi)

TS_PRIMARY_DIR := $(shell echo $(TS_DIRS) | cut -d' ' -f1)

# For legacy compatibility, use primary dir for single-dir variables
TS_DIR := $(TS_PRIMARY_DIR)
TS_FILES := $(shell \
	for dir in $(TS_DIRS); do \
		if [ -d "$$dir" ]; then \
			find $$dir -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null || true; \
		fi; \
	done)

# =============================================================================
# TypeScript Tool Installation
# =============================================================================

install-tools-typescript: ## Install TypeScript development tools
	@if [ -d "$(TS_DIR)" ]; then \
		echo "$(YELLOW)Installing TypeScript tools...$(RESET)"; \
		cd $(TS_DIR) && $(NPM) install --save-dev \
			prettier@^3.6.2 \
			eslint@^9.33.0 \
			@typescript-eslint/parser@^8.40.0 \
			@typescript-eslint/eslint-plugin@^8.40.0 \
			eslint-config-prettier@^9.1.0 \
			eslint-plugin-import@^2.29.1 \
			eslint-plugin-prettier@^5.1.3; \
		echo "$(GREEN)TypeScript tools installed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping TypeScript tools (no TypeScript project detected)$(RESET)"; \
	fi

check-tools-typescript: ## Check TypeScript development tools
	@if [ -d "$(TS_DIR)" ]; then \
		echo "$(YELLOW)Checking TypeScript tools...$(RESET)"; \
		command -v node >/dev/null 2>&1 || (echo "$(RED)Node.js is not installed$(RESET)" && exit 1); \
		command -v $(NPM) >/dev/null 2>&1 || (echo "$(RED)npm is not installed$(RESET)" && exit 1); \
		if [ -d "$(TS_DIR)" ]; then \
			(cd $(TS_DIR) && $(NPM) list typescript >/dev/null 2>&1) || echo "$(RED)TypeScript is not installed. Run 'make install-tools-typescript'$(RESET)"; \
			(cd $(TS_DIR) && $(NPM) list prettier >/dev/null 2>&1) || echo "$(RED)Prettier is not installed. Run 'make install-tools-typescript'$(RESET)"; \
			(cd $(TS_DIR) && $(NPM) list eslint >/dev/null 2>&1) || echo "$(RED)ESLint is not installed. Run 'make install-tools-typescript'$(RESET)"; \
		else \
			echo "$(RED)TypeScript directory $(TS_DIR) not found$(RESET)"; \
		fi; \
		echo "$(GREEN)TypeScript tools available$(RESET)"; \
	else \
		echo "$(BLUE)Skipping TypeScript tools (no TypeScript project detected)$(RESET)"; \
	fi

# =============================================================================
# TypeScript Code Formatting
# =============================================================================

fmt-typescript: ## Format TypeScript code (all configured TypeScript projects)
	@if [ -n "$(TS_DIRS)" ]; then \
		echo "$(YELLOW)Formatting TypeScript code in: $(TS_DIRS)$(RESET)"; \
		for dir in $(TS_DIRS); do \
			if [ -d "$$dir" ]; then \
				echo "$(YELLOW)  Processing $$dir...$(RESET)"; \
				cd $$dir && npx $(PRETTIER) --write "**/*.{ts,tsx,js,jsx,json,md}"; \
				cd - > /dev/null; \
			else \
				echo "$(RED)    Directory $$dir does not exist$(RESET)"; \
			fi; \
		done; \
		echo "$(GREEN)TypeScript code formatting completed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping TypeScript formatting (no TypeScript projects configured)$(RESET)"; \
	fi

# =============================================================================
# TypeScript Code Quality Checks
# =============================================================================

check-typescript: ## Check TypeScript code quality (all configured TypeScript projects)
	@if [ -n "$(TS_DIRS)" ]; then \
		echo "$(YELLOW)Checking TypeScript code quality in: $(TS_DIRS)$(RESET)"; \
		for dir in $(TS_DIRS); do \
			if [ -d "$$dir" ]; then \
				echo "$(YELLOW)  Processing $$dir...$(RESET)"; \
				cd $$dir; \
				echo "$(YELLOW)    Running TypeScript type checking...$(RESET)" && \
				npm run type-check:ci && \
				echo "$(YELLOW)    Running ESLint...$(RESET)" && \
				npm run lint; \
				cd - > /dev/null; \
			else \
				echo "$(RED)    Directory $$dir does not exist$(RESET)"; \
			fi; \
		done; \
		echo "$(GREEN)TypeScript code quality checks completed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping TypeScript checks (no TypeScript projects configured)$(RESET)"; \
	fi

# Show TypeScript project information

info-typescript: ## Show TypeScript project information
	@echo "$(BLUE)TypeScript Project Information:$(RESET)"
	@echo "  TypeScript files: $(words $(TS_FILES))"
	@if [ -d "$(TS_DIR)" ]; then \
		echo "  Node version: $$(node --version)"; \
		echo "  NPM version: $$(npm --version)"; \
		cd $(TS_DIR) && echo "  TypeScript version: $$(npx tsc --version)"; \
	fi

# Format check (without modifying files)
fmt-check-typescript: ## Check if TypeScript code format meets standards (without modifying files)
	@echo "$(YELLOW)Checking TypeScript code formatting...$(RESET)"
	@if [ -d "$(TS_DIR)" ]; then \
		cd $(TS_DIR) && npx $(PRETTIER) --check "**/*.{ts,tsx,js,jsx,json,md}" || (echo "$(RED)TypeScript code is not formatted. Run 'make fmt-typescript' to fix.$(RESET)" && exit 1); \
	fi
	@echo "$(GREEN)TypeScript code formatting checks passed$(RESET)"

# =============================================================================
# Individual TypeScript Quality Check Tools
# =============================================================================

check-eslint-typescript: ## Run ESLint syntax and style checks
	@echo "$(YELLOW)Running ESLint checks...$(RESET)"
	@if [ -d "$(TS_DIR)" ]; then \
		cd $(TS_DIR) && npx $(ESLINT) "**/*.{ts,tsx}"; \
		echo "$(GREEN)ESLint checks passed$(RESET)"; \
	fi

check-tsc-typescript: ## Run TypeScript type checking
	@echo "$(YELLOW)Running TypeScript type checking...$(RESET)"
	@if [ -d "$(TS_DIR)" ]; then \
		cd $(TS_DIR) && npx $(TSC) --noEmit; \
		echo "$(GREEN)TypeScript type checking passed$(RESET)"; \
	fi

# =============================================================================
# Legacy aliases for backward compatibility
# =============================================================================

install-tools-ts: install-tools-typescript
check-tools-ts: check-tools-typescript
fmt-ts: fmt-typescript
check-ts: check-typescript
info-ts: info-typescript
fmt-check-ts: fmt-check-typescript
