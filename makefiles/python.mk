# =============================================================================
# Python Language Support - Makefile Module
# =============================================================================

# Python project variables - use dynamic directories from config
PYTHON := /Users/scguo/.virtualenvs/mydemos/bin/python
BLACK := black
ISORT := isort
FLAKE8 := flake8
MYPY := mypy
PYLINT := pylint

# Get all Python directories from config - use shell directly to avoid function call issues
PYTHON_DIRS := $(shell \
	if [ -n "$(LOCALCI_CONFIG)" ] && [ -f "$(LOCALCI_CONFIG)" ]; then \
		scripts/parse_localci.sh enabled python $(LOCALCI_CONFIG) | cut -d'|' -f2 | tr '\n' ' '; \
	else \
		echo "demo-apps/backends/python"; \
	fi)

PYTHON_PRIMARY_DIR := $(shell echo $(PYTHON_DIRS) | cut -d' ' -f1)

# For legacy compatibility, use primary dir for single-dir variables
PYTHON_DIR := $(PYTHON_PRIMARY_DIR)
PYTHON_FILES := $(shell \
	for dir in $(PYTHON_DIRS); do \
		if [ -d "$$dir" ]; then \
			find $$dir -name "*.py" 2>/dev/null || true; \
		fi; \
	done)

# =============================================================================
# Python Tool Installation
# =============================================================================

install-tools-python: ## Install Python development tools
	@if [ -d "$(PYTHON_DIR)" ]; then \
		echo "$(YELLOW)Installing Python tools...$(RESET)"; \
		$(PYTHON) -m pip install \
			black==24.4.2 \
			isort==5.13.2 \
			flake8==7.0.0 \
			mypy==1.9.0 \
			pylint==3.1.0; \
		echo "$(GREEN)Python tools installed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Python tools (no Python project detected)$(RESET)"; \
	fi

check-tools-python: ## Check Python development tools
	@if [ -d "$(PYTHON_DIR)" ]; then \
		echo "$(YELLOW)Checking Python tools...$(RESET)"; \
		test -f $(PYTHON) || (echo "$(RED)Python virtual environment not found at $(PYTHON)$(RESET)" && exit 1); \
		$(PYTHON) -c "import black" 2>/dev/null || (echo "$(RED)black is not installed. Run 'make install-tools-python'$(RESET)" && exit 1); \
		$(PYTHON) -c "import isort" 2>/dev/null || (echo "$(RED)isort is not installed. Run 'make install-tools-python'$(RESET)" && exit 1); \
		$(PYTHON) -c "import flake8" 2>/dev/null || (echo "$(RED)flake8 is not installed. Run 'make install-tools-python'$(RESET)" && exit 1); \
		$(PYTHON) -c "import mypy" 2>/dev/null || (echo "$(RED)mypy is not installed. Run 'make install-tools-python'$(RESET)" && exit 1); \
		$(PYTHON) -c "import pylint" 2>/dev/null || (echo "$(RED)pylint is not installed. Run 'make install-tools-python'$(RESET)" && exit 1); \
		echo "$(GREEN)Python tools available$(RESET)"; \
	fi

# =============================================================================
# Python Code Formatting
# =============================================================================

fmt-python: ## Format Python code (all configured Python projects)
	@if [ -n "$(PYTHON_DIRS)" ]; then \
		echo "$(YELLOW)Formatting Python code in: $(PYTHON_DIRS)$(RESET)"; \
		for dir in $(PYTHON_DIRS); do \
			if [ -d "$$dir" ]; then \
				echo "$(YELLOW)  Processing $$dir...$(RESET)"; \
				cd $$dir && \
				$(PYTHON) -m $(ISORT) . && \
				$(PYTHON) -m $(BLACK) .; \
				cd - > /dev/null; \
			else \
				echo "$(RED)    Directory $$dir does not exist$(RESET)"; \
			fi; \
		done; \
		echo "$(GREEN)Python code formatting completed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Python formatting (no Python projects configured)$(RESET)"; \
	fi

# =============================================================================
# Python Code Quality Checks
# =============================================================================

check-python: ## Check Python code quality (all configured Python projects)
	@if [ -n "$(PYTHON_DIRS)" ]; then \
		echo "$(YELLOW)Checking Python code quality in: $(PYTHON_DIRS)$(RESET)"; \
		for dir in $(PYTHON_DIRS); do \
			if [ -d "$$dir" ]; then \
				echo "$(YELLOW)  Processing $$dir...$(RESET)"; \
				cd $$dir && \
				echo "$(YELLOW)    Running flake8...$(RESET)" && \
				$(PYTHON) -m $(FLAKE8) . && \
				echo "$(YELLOW)    Running mypy...$(RESET)" && \
				$(PYTHON) -m $(MYPY) . && \
				echo "$(YELLOW)    Running pylint...$(RESET)" && \
				$(PYTHON) -m $(PYLINT) --fail-under=8.0 *.py; \
				cd - > /dev/null; \
			else \
				echo "$(RED)    Directory $$dir does not exist$(RESET)"; \
			fi; \
		done; \
		echo "$(GREEN)Python code quality checks completed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Python checks (no Python projects configured)$(RESET)"; \
	fi

# Show Python project information
info-python: ## Show Python project information
	@echo "$(BLUE)Python Project Information:$(RESET)"
	@echo "  Python files: $(words $(PYTHON_FILES))"
	@if [ -d "$(PYTHON_DIR)" ]; then \
		echo "  Python version: $$($(PYTHON) --version)"; \
		echo "  Pip version: $$($(PYTHON) -m pip --version)"; \
	fi

# Format check (without modifying files)
fmt-check-python: ## Check if Python code format meets standards (without modifying files)
	@echo "$(YELLOW)Checking Python code formatting...$(RESET)"
	@if [ -d "$(PYTHON_DIR)" ]; then \
		cd $(PYTHON_DIR) && \
		$(PYTHON) -m $(ISORT) --check-only . && \
		$(PYTHON) -m $(BLACK) --check . || \
		(echo "$(RED)Python code is not formatted. Run 'make fmt-python' to fix.$(RESET)" && exit 1); \
	fi
	@echo "$(GREEN)Python code formatting checks passed$(RESET)"

# =============================================================================
# Individual Python Quality Check Tools
# =============================================================================

check-flake8-python: ## Run flake8 syntax and style checks
	@echo "$(YELLOW)Running flake8 checks...$(RESET)"
	@if [ -d "$(PYTHON_DIR)" ]; then \
		cd $(PYTHON_DIR) && $(PYTHON) -m $(FLAKE8) .; \
		echo "$(GREEN)Flake8 checks passed$(RESET)"; \
	fi

check-mypy-python: ## Run mypy type checking
	@echo "$(YELLOW)Running mypy type checking...$(RESET)"
	@if [ -d "$(PYTHON_DIR)" ]; then \
		cd $(PYTHON_DIR) && $(PYTHON) -m $(MYPY) .; \
		echo "$(GREEN)MyPy type checking passed$(RESET)"; \
	fi

check-pylint-python: ## Run pylint static analysis
	@echo "$(YELLOW)Running pylint static analysis...$(RESET)"
	@if [ -d "$(PYTHON_DIR)" ]; then \
		cd $(PYTHON_DIR) && $(PYTHON) -m $(PYLINT) --fail-under=8.0 *.py; \
		echo "$(GREEN)Pylint analysis passed$(RESET)"; \
	fi

# =============================================================================
# Python Testing and Coverage
# =============================================================================

test-python: ## Run Python tests (all configured Python projects)
	@if [ -n "$(PYTHON_DIRS)" ]; then \
		echo "$(YELLOW)Running Python tests in: $(PYTHON_DIRS)$(RESET)"; \
		for dir in $(PYTHON_DIRS); do \
			if [ -d "$$dir" ]; then \
				echo "$(YELLOW)  Testing $$dir...$(RESET)"; \
				cd $$dir && $(PYTHON) -m pytest tests/ -v; \
				cd - > /dev/null; \
			else \
				echo "$(RED)    Directory $$dir does not exist$(RESET)"; \
			fi; \
		done; \
		echo "$(GREEN)Python tests completed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Python tests (no Python projects configured)$(RESET)"; \
	fi

coverage-python: ## Run Python tests with coverage
	@if [ -d "$(PYTHON_DIR)" ]; then \
		echo "$(YELLOW)Running Python coverage...$(RESET)"; \
		cd $(PYTHON_DIR) && \
		$(PYTHON) -m pytest tests/ --cov=app --cov-report=term --cov-report=html:coverage_html; \
		echo "$(GREEN)Coverage report generated: $(PYTHON_DIR)/coverage_html/index.html$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Python coverage (no Python project)$(RESET)"; \
	fi

# =============================================================================
# Python Application Management
# =============================================================================

run-python: ## Run Python FastAPI service (first configured Python project)
	@if [ -n "$(PYTHON_DIRS)" ]; then \
		first_dir=$$(echo $(PYTHON_DIRS) | cut -d' ' -f1); \
		if [ -d "$$first_dir" ]; then \
			echo "$(YELLOW)Starting Python FastAPI service from $$first_dir... (Ctrl+C to stop)$(RESET)"; \
			if [ $$(echo $(PYTHON_DIRS) | wc -w) -gt 1 ]; then \
				echo "$(BLUE)Note: Multiple Python projects detected ($(PYTHON_DIRS)). Running first one: $$first_dir$(RESET)"; \
			fi; \
			cd $$first_dir && $(PYTHON) main.py; \
		else \
			echo "$(RED)Python directory $$first_dir does not exist$(RESET)"; \
		fi; \
	else \
		echo "$(BLUE)No Python projects configured to run$(RESET)"; \
	fi

install-deps-python: ## Install Python dependencies
	@if [ -d "$(PYTHON_DIR)" ]; then \
		echo "$(YELLOW)Installing Python dependencies...$(RESET)"; \
		cd $(PYTHON_DIR) && $(PYTHON) -m pip install -r requirements.txt; \
		echo "$(GREEN)Python dependencies installed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Python dependencies (no Python project)$(RESET)"; \
	fi

lint-python: ## Run comprehensive Python linting (flake8 + mypy + pylint)
	@if [ -d "$(PYTHON_DIR)" ]; then \
		echo "$(YELLOW)Running comprehensive Python linting...$(RESET)"; \
		make check-flake8-python && \
		make check-mypy-python && \
		make check-pylint-python; \
		echo "$(GREEN)All Python linting checks passed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Python linting (no Python project)$(RESET)"; \
	fi
