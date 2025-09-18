# =============================================================================
# TypeScript Language Support - Makefile Module
# =============================================================================

# TypeScript project variables - use dynamic directories from config
NPM := npm
PRETTIER := prettier
ESLINT := eslint
TSC := typescript

# Get all TypeScript directories from config
TS_DIRS := $(shell \
	if [ -n "$(LOCALCI_CONFIG)" ] && [ -f "$(LOCALCI_CONFIG)" ]; then \
		scripts/parse_localci.sh enabled typescript $(LOCALCI_CONFIG) | cut -d'|' -f2 | tr '\n' ' '; \
	else \
		echo "demo-apps/frontends/typescript"; \
	fi)

TS_PRIMARY_DIR := $(shell echo $(TS_DIRS) | cut -d' ' -f1)
TS_DIR := $(TS_PRIMARY_DIR)
TS_FILES := $(shell \
	for dir in $(TS_DIRS); do \
		if [ -d "$$dir" ]; then \
			find $$dir -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null || true; \
		fi; \
	done)

# =============================================================================
# Core TypeScript Commands
# =============================================================================

install-tools-typescript: ## 🛠️ Install TypeScript development tools
	@if [ -d "$(TS_DIR)" ]; then \
		echo "$(YELLOW)Installing TypeScript tools...$(RESET)"; \
		cd $(TS_DIR) && $(NPM) install --save-dev \
			typescript@^5.0.0 \
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

check-tools-typescript: ## ✅ Check TypeScript development tools availability
	@if [ -d "$(TS_DIR)" ]; then \
		echo "$(YELLOW)Checking TypeScript tools...$(RESET)"; \
		command -v node >/dev/null 2>&1 || (echo "$(RED)Node.js is not installed$(RESET)" && exit 1); \
		command -v $(NPM) >/dev/null 2>&1 || (echo "$(RED)npm is not installed$(RESET)" && exit 1); \
		(cd $(TS_DIR) && $(NPM) list typescript >/dev/null 2>&1) || (echo "$(RED)TypeScript is not installed. Run 'make install-tools-typescript'$(RESET)" && exit 1); \
		(cd $(TS_DIR) && $(NPM) list prettier >/dev/null 2>&1) || (echo "$(RED)Prettier is not installed. Run 'make install-tools-typescript'$(RESET)" && exit 1); \
		(cd $(TS_DIR) && $(NPM) list eslint >/dev/null 2>&1) || (echo "$(RED)ESLint is not installed. Run 'make install-tools-typescript'$(RESET)" && exit 1); \
		echo "$(GREEN)TypeScript tools available$(RESET)"; \
		echo "  TypeScript files: $(words $(TS_FILES))"; \
		echo "  Node version: $$(node --version)"; \
		echo "  NPM version: $$(npm --version)"; \
		if [ -d "$(TS_DIR)" ]; then \
			cd $(TS_DIR) && echo "  TypeScript version: $$(npx tsc --version)"; \
		fi; \
	fi

fmt-typescript: ## ✨ Format TypeScript code
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

check-typescript: ## 🔍 Check TypeScript code quality
	@if [ -n "$(TS_DIRS)" ]; then \
		echo "$(YELLOW)Checking TypeScript code quality in: $(TS_DIRS)$(RESET)"; \
		for dir in $(TS_DIRS); do \
			if [ -d "$$dir" ]; then \
				echo "$(YELLOW)  Processing $$dir...$(RESET)"; \
				cd $$dir; \
				echo "$(YELLOW)    Checking format compliance...$(RESET)" && \
				npx $(PRETTIER) --check "**/*.{ts,tsx,js,jsx,json,md}" && \
				echo "$(YELLOW)    Running TypeScript type checking...$(RESET)" && \
				npx tsc --noEmit && \
				echo "$(YELLOW)    Running ESLint...$(RESET)" && \
				npx $(ESLINT) "**/*.{ts,tsx,js,jsx}"; \
				cd - > /dev/null; \
			else \
				echo "$(RED)    Directory $$dir does not exist$(RESET)"; \
			fi; \
		done; \
		echo "$(GREEN)TypeScript code quality checks completed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping TypeScript checks (no TypeScript projects configured)$(RESET)"; \
	fi

test-typescript: ## 🧪 Run TypeScript tests
	@if [ -n "$(TS_DIRS)" ]; then \
		echo "$(YELLOW)Running TypeScript tests in: $(TS_DIRS)$(RESET)"; \
		for dir in $(TS_DIRS); do \
			if [ -d "$$dir" ]; then \
				echo "$(YELLOW)  Testing $$dir...$(RESET)"; \
				cd $$dir; \
				if [ -f package.json ] && grep -q '"test"' package.json; then \
					$(NPM) test; \
				else \
					echo "$(BLUE)    No test script found in package.json$(RESET)"; \
				fi; \
				cd - > /dev/null; \
			else \
				echo "$(RED)    Directory $$dir does not exist$(RESET)"; \
			fi; \
		done; \
		echo "$(GREEN)TypeScript tests completed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping TypeScript tests (no TypeScript projects configured)$(RESET)"; \
	fi

build-typescript: ## 📦 Build TypeScript projects
	@if [ -n "$(TS_DIRS)" ]; then \
		echo "$(YELLOW)Building TypeScript projects in: $(TS_DIRS)$(RESET)"; \
		for dir in $(TS_DIRS); do \
			if [ -d "$$dir" ]; then \
				echo "$(YELLOW)  Building $$dir...$(RESET)"; \
				cd $$dir; \
				if [ -f package.json ]; then \
					$(NPM) ci --prefer-offline; \
					if grep -q '"build"' package.json; then \
						$(NPM) run build; \
						echo "$(GREEN)  Built: $$dir$(RESET)"; \
					else \
						echo "$(BLUE)  No build script found in $$dir/package.json$(RESET)"; \
					fi; \
				else \
					echo "$(RED)  No package.json found in $$dir$(RESET)"; \
				fi; \
				cd - > /dev/null; \
			else \
				echo "$(RED)    Directory $$dir does not exist$(RESET)"; \
			fi; \
		done; \
		echo "$(GREEN)TypeScript build completed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping TypeScript build (no TypeScript projects configured)$(RESET)"; \
	fi

clean-typescript: ## 🧹 Clean TypeScript build artifacts
	@if [ -n "$(TS_DIRS)" ]; then \
		echo "$(YELLOW)Cleaning TypeScript build artifacts in: $(TS_DIRS)$(RESET)"; \
		for dir in $(TS_DIRS); do \
			if [ -d "$$dir" ]; then \
				echo "$(YELLOW)  Cleaning $$dir...$(RESET)"; \
				cd $$dir && \
				rm -rf dist/ build/ .next/ out/ coverage/ && \
				rm -rf node_modules/.cache/ .eslintcache .tsbuildinfo && \
				echo "$(GREEN)  Cleaned: $$dir$(RESET)"; \
				cd - > /dev/null; \
			else \
				echo "$(RED)    Directory $$dir does not exist$(RESET)"; \
			fi; \
		done; \
		echo "$(GREEN)TypeScript build artifacts cleaned$(RESET)"; \
	else \
		echo "$(BLUE)Skipping TypeScript clean (no TypeScript projects configured)$(RESET)"; \
	fi