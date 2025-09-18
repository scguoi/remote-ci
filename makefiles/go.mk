# =============================================================================
# Go Language Support - Makefile Module
# =============================================================================

# Go tool definitions
GOIMPORTS := goimports
GOFUMPT := gofumpt
GOLINES := golines
GOCYCLO := gocyclo
STATICCHECK := staticcheck
GOLANGCI_LINT := golangci-lint

# Go project variables
GO := go
GOFILES := $(shell find backend-go -name "*.go" 2>/dev/null || true)
GOMODULES := $(shell cd backend-go && $(GO) list -m 2>/dev/null || echo "No Go module")

# Go app paths
GO_DIR := backend-go
GO_CMD := $(GO_DIR)/cmd/server
GO_BIN_DIR := $(GO_DIR)/bin
GO_BIN := $(GO_BIN_DIR)/server
COVER_DIR := $(GO_DIR)/coverage

# =============================================================================
# Go Tool Installation
# =============================================================================

install-tools-go: ## Install Go development tools
	@if [ -d "$(GO_DIR)" ]; then \
		echo "$(YELLOW)Installing Go tools...$(RESET)"; \
		$(GO) install golang.org/x/tools/cmd/goimports@latest; \
		$(GO) install mvdan.cc/gofumpt@latest; \
		$(GO) install github.com/segmentio/golines@latest; \
		$(GO) install github.com/fzipp/gocyclo/cmd/gocyclo@latest; \
		$(GO) install honnef.co/go/tools/cmd/staticcheck@2025.1.1; \
		$(GO) install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.3.0; \
		echo "$(GREEN)Go tools installed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Go tools (no Go project detected)$(RESET)"; \
	fi

check-tools-go: ## Check Go development tools
	@if [ -d "$(GO_DIR)" ]; then \
		echo "$(YELLOW)Checking Go tools...$(RESET)"; \
		command -v $(GO) >/dev/null 2>&1 || (echo "$(RED)go is not installed$(RESET)" && exit 1); \
		command -v $(GOIMPORTS) >/dev/null 2>&1 || (echo "$(RED)goimports is not installed. Run 'make install-tools-go'$(RESET)" && exit 1); \
		command -v $(GOFUMPT) >/dev/null 2>&1 || (echo "$(RED)gofumpt is not installed. Run 'make install-tools-go'$(RESET)" && exit 1); \
		command -v $(GOLINES) >/dev/null 2>&1 || (echo "$(RED)golines is not installed. Run 'make install-tools-go'$(RESET)" && exit 1); \
		command -v $(GOCYCLO) >/dev/null 2>&1 || (echo "$(RED)gocyclo is not installed. Run 'make install-tools-go'$(RESET)" && exit 1); \
		command -v $(STATICCHECK) >/dev/null 2>&1 || (echo "$(RED)staticcheck is not installed. Run 'make install-tools-go'$(RESET)" && exit 1); \
		command -v $(GOLANGCI_LINT) >/dev/null 2>&1 || (echo "$(RED)golangci-lint is not installed. Run 'make install-tools-go'$(RESET)" && exit 1); \
		echo "$(GREEN)Go tools available$(RESET)"; \
	fi

# =============================================================================
# Go Code Formatting
# =============================================================================

fmt-go: ## Format Go code
	@if [ -d "$(GO_DIR)" ]; then \
		echo "$(YELLOW)Formatting Go code...$(RESET)"; \
		if [ -n "$(GOFILES)" ]; then \
			if command -v $(GOIMPORTS) >/dev/null 2>&1; then \
				$(GOIMPORTS) -w $(GOFILES) >/dev/null 2>&1 || true; \
			fi; \
			if command -v $(GOFUMPT) >/dev/null 2>&1; then \
				$(GOFUMPT) -w $(GOFILES) >/dev/null 2>&1 || true; \
			fi; \
			if command -v $(GOLINES) >/dev/null 2>&1; then \
				$(GOLINES) -w -m 120 $(GOFILES) >/dev/null 2>&1 || true; \
			fi; \
		else \
			echo "$(BLUE)No Go files found to format$(RESET)"; \
		fi; \
		echo "$(GREEN)Go code formatted$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Go formatting (no Go project)$(RESET)"; \
	fi

# =============================================================================
# Go Code Quality Checks
# =============================================================================

check-go: ## Check Go code quality
	@if [ -d "$(GO_DIR)" ]; then \
		echo "$(YELLOW)Checking Go code quality...$(RESET)"; \
		cd backend-go; \
		if command -v $(GOCYCLO) >/dev/null 2>&1; then \
			echo "$(YELLOW)Running gocyclo...$(RESET)"; \
			$(GOCYCLO) -over 10 . || (echo "$(RED)High cyclomatic complexity detected$(RESET)" && exit 1); \
		else \
			echo "$(YELLOW)gocyclo not available, skipping complexity check$(RESET)"; \
		fi; \
		if command -v $(STATICCHECK) >/dev/null 2>&1; then \
			echo "$(YELLOW)Running staticcheck...$(RESET)"; \
			PKGS="$$(go list ./... 2>/dev/null)"; \
			if [ -n "$$PKGS" ]; then \
				$(STATICCHECK) $$PKGS 2>/dev/null || true; \
			else \
				echo "$(BLUE)No Go packages found; skipping staticcheck$(RESET)"; \
			fi; \
		else \
			echo "$(YELLOW)staticcheck not available, skipping static analysis$(RESET)"; \
		fi; \
		if command -v $(GOLANGCI_LINT) >/dev/null 2>&1; then \
			echo "$(YELLOW)Running golangci-lint...$(RESET)"; \
			PKGS="$$(go list ./... 2>/dev/null)"; \
			if [ -n "$$PKGS" ]; then \
				GOCACHE=$$(pwd)/.gocache GOLANGCI_LINT_CACHE=$$(pwd)/.golangci-cache $(GOLANGCI_LINT) run ./... 2>/dev/null || true; \
			else \
				echo "$(BLUE)No Go packages found; skipping golangci-lint$(RESET)"; \
			fi; \
		else \
			echo "$(YELLOW)golangci-lint not available, skipping lint check$(RESET)"; \
		fi; \
		echo "$(GREEN)Go code quality checks completed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Go checks (no Go project)$(RESET)"; \
	fi

# =============================================================================
# Go Specific Quality Check Tools
# =============================================================================

check-gocyclo: check-gocyclo-tool ## Check cyclomatic complexity
	@echo "$(YELLOW)Running gocyclo check...$(RESET)"
	@$(GOCYCLO) -over 10 $(GOFILES) || (echo "$(RED)High cyclomatic complexity detected$(RESET)" && exit 1)
	@echo "$(GREEN)Cyclomatic complexity check passed$(RESET)"

check-staticcheck: check-staticcheck-tool ## Run static analysis checks
	@echo "$(YELLOW)Running staticcheck...$(RESET)"
	@$(STATICCHECK) ./...
	@echo "$(GREEN)Staticcheck passed$(RESET)"

explain-staticcheck: check-staticcheck-tool ## Explain staticcheck error codes (usage: make explain-staticcheck code=ST1008)
	@if [ -z "$(code)" ]; then \
		echo "$(RED)Please provide error code, example: make explain-staticcheck code=ST1008$(RESET)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Explaining staticcheck error code $(code):$(RESET)"
	@$(STATICCHECK) -explain $(code)

check-golangci-lint: check-golangci-lint-tool ## Run comprehensive golangci-lint checks
	@echo "$(YELLOW)Running golangci-lint...$(RESET)"
	@$(GOLANGCI_LINT) run ./...
	@echo "$(GREEN)Golangci-lint check passed$(RESET)"

# Check individual tools
check-gocyclo-tool:
	@command -v $(GOCYCLO) >/dev/null 2>&1 || (echo "$(RED)gocyclo is not installed. Run 'make install-tools'$(RESET)" && exit 1)

check-staticcheck-tool:
	@command -v $(STATICCHECK) >/dev/null 2>&1 || (echo "$(RED)staticcheck is not installed. Run 'make install-tools'$(RESET)" && exit 1)

check-golangci-lint-tool:
	@command -v $(GOLANGCI_LINT) >/dev/null 2>&1 || (echo "$(RED)golangci-lint is not installed. Run 'make install-tools'$(RESET)" && exit 1)

check-gofumpt:
	@command -v $(GOFUMPT) >/dev/null 2>&1 || (echo "$(RED)gofumpt is not installed. Run 'make install-tools'$(RESET)" && exit 1)

check-golines:
	@command -v $(GOLINES) >/dev/null 2>&1 || (echo "$(RED)golines is not installed. Run 'make install-tools'$(RESET)" && exit 1)

# Show Go project information
info-go: ## Show Go project information
	@echo "$(BLUE)Go Project Information:$(RESET)"
	@echo "  Module: $(GOMODULES)"
	@echo "  Go files: $(words $(GOFILES))"
	@echo "  Go version: $$($(GO) version)"

# Format check (without modifying files)
fmt-check-go: ## Check if Go code format meets standards (without modifying files)
	@echo "$(YELLOW)Checking Go code formatting...$(RESET)"
	@if [ -d "$(GO_DIR)" ]; then \
		CHANGED=""; \
		if [ -n "$(GOFILES)" ]; then \
			if command -v $(GOIMPORTS) >/dev/null 2>&1; then \
				GI_CHANGED="$$($(GOIMPORTS) -l $(GOFILES))"; \
				if [ -n "$$GI_CHANGED" ]; then \
					CHANGED="$$CHANGED $$GI_CHANGED"; \
				fi; \
			fi; \
			if command -v $(GOFUMPT) >/dev/null 2>&1; then \
				GF_CHANGED="$$($(GOFUMPT) -l $(GOFILES))"; \
				if [ -n "$$GF_CHANGED" ]; then \
					CHANGED="$$CHANGED $$GF_CHANGED"; \
				fi; \
			fi; \
		fi; \
		if [ -n "$$CHANGED" ]; then \
			echo "$(RED)Go code is not formatted according to goimports/gofumpt.$(RESET)"; \
			echo "Files:"; echo "$$CHANGED" | tr ' ' '\n' | sort -u; \
			echo "$(YELLOW)Run 'make fmt-go' to auto-fix.$(RESET)"; \
			exit 1; \
		fi; \
	fi
	@echo "$(GREEN)Go code formatting checks passed$(RESET)"

# =============================================================================
# Go Build, Test, and Run
# =============================================================================

build-go: ## Build Go service binary
	@if [ -d "$(GO_DIR)" ]; then \
		echo "$(YELLOW)Building Go service...$(RESET)"; \
		mkdir -p $(GO_BIN_DIR); \
		cd $(GO_DIR) && GOCACHE=$$(pwd)/.gocache $(GO) build -o bin/server ./cmd/server; \
		echo "$(GREEN)Built: $(GO_BIN)$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Go build (no Go project)$(RESET)"; \
	fi

run-go: ## Run Go service locally (loads backend-go/.env)
	@if [ -d "$(GO_DIR)" ]; then \
		echo "$(YELLOW)Starting Go service... (Ctrl+C to stop)$(RESET)"; \
		cd $(GO_DIR) && $(GO) run ./cmd/server; \
	else \
		echo "$(BLUE)No Go project to run$(RESET)"; \
	fi

test-go: ## Run Go tests
	@if [ -d "$(GO_DIR)" ]; then \
		echo "$(YELLOW)Running Go tests...$(RESET)"; \
		cd $(GO_DIR) && GOCACHE=$$(pwd)/.gocache $(GO) test ./internal/... -v; \
		echo "$(GREEN)Go tests completed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Go tests (no Go project)$(RESET)"; \
	fi

coverage-go: ## Run Go tests with coverage report (text + HTML)
	@if [ -d "$(GO_DIR)" ]; then \
		echo "$(YELLOW)Running Go coverage...$(RESET)"; \
		mkdir -p $(COVER_DIR); \
		cd $(GO_DIR) && GOCACHE=$$(pwd)/.gocache $(GO) test -covermode=atomic -coverprofile=coverage/coverage.out ./internal/... && \
		$(GO) tool cover -func=coverage/coverage.out && \
		$(GO) tool cover -html=coverage/coverage.out -o coverage/coverage.html; \
		echo "$(GREEN)Coverage report: $(COVER_DIR)/coverage.out, HTML: $(COVER_DIR)/coverage.html$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Go coverage (no Go project)$(RESET)"; \
	fi
