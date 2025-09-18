# =============================================================================
# Comment Language Check - English Comments Enforcement
# =============================================================================

# Comment check script path
COMMENT_CHECK_SCRIPT := makefiles/check-comments.sh

# =============================================================================
# Comment Language Check Commands
# =============================================================================

check-comments: ## Check that all comments are written in English
	@if [ ! -f "$(COMMENT_CHECK_SCRIPT)" ]; then \
		echo "$(RED)Comment check script not found: $(COMMENT_CHECK_SCRIPT)$(RESET)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🔍 Checking comment language compliance...$(RESET)"
	@./$(COMMENT_CHECK_SCRIPT)

check-comments-go: ## Check Go comments for English language
	@if [ -d "backend-go" ]; then \
		echo "$(YELLOW)Checking Go comments...$(RESET)"; \
		find backend-go -name "*.go" -exec grep -l '//' {} \; 2>/dev/null | head -5 | while read file; do \
			echo "  Checking: $$file"; \
			grep -n '//' "$$file" | while IFS=: read -r line_num comment; do \
				comment_text=$$(echo "$$comment" | sed 's|^\s*//\s*||'); \
				if echo "$$comment_text" | grep -qP '[\x{4e00}-\x{9fff}]' 2>/dev/null; then \
					echo "    $(RED)Line $$line_num: Contains Chinese characters$(RESET)"; \
					echo "    Content: $$comment_text"; \
				fi; \
			done; \
		done; \
	else \
		echo "$(BLUE)Skipping Go comment check (no Go project)$(RESET)"; \
	fi

check-comments-java: ## Check Java comments for English language
	@if [ -d "backend-java" ]; then \
		echo "$(YELLOW)Checking Java comments...$(RESET)"; \
		find backend-java -name "*.java" -exec grep -l '//' {} \; 2>/dev/null | head -5 | while read file; do \
			echo "  Checking: $$file"; \
			grep -n '//' "$$file" | while IFS=: read -r line_num comment; do \
				comment_text=$$(echo "$$comment" | sed 's|^\s*//\s*||'); \
				if echo "$$comment_text" | grep -qP '[\x{4e00}-\x{9fff}]' 2>/dev/null; then \
					echo "    $(RED)Line $$line_num: Contains Chinese characters$(RESET)"; \
					echo "    Content: $$comment_text"; \
				fi; \
			done; \
		done; \
	else \
		echo "$(BLUE)Skipping Java comment check (no Java project)$(RESET)"; \
	fi

check-comments-python: ## Check Python comments for English language
	@if [ -d "backend-python" ]; then \
		echo "$(YELLOW)Checking Python comments...$(RESET)"; \
		find backend-python -name "*.py" -exec grep -l '#' {} \; 2>/dev/null | head -5 | while read file; do \
			echo "  Checking: $$file"; \
			grep -n '#' "$$file" | while IFS=: read -r line_num comment; do \
				comment_text=$$(echo "$$comment" | sed 's|^\s*#\s*||'); \
				if echo "$$comment_text" | grep -qP '[\x{4e00}-\x{9fff}]' 2>/dev/null; then \
					echo "    $(RED)Line $$line_num: Contains Chinese characters$(RESET)"; \
					echo "    Content: $$comment_text"; \
				fi; \
			done; \
		done; \
	else \
		echo "$(BLUE)Skipping Python comment check (no Python project)$(RESET)"; \
	fi

check-comments-typescript: ## Check TypeScript comments for English language
	@if [ "$(HAS_TYPESCRIPT)" = "true" ]; then \
		echo "$(YELLOW)Checking TypeScript comments...$(RESET)"; \
		find frontend-ts -name "*.ts" -o -name "*.tsx" | grep -v node_modules | head -5 | while read file; do \
			echo "  Checking: $$file"; \
			grep -n '//' "$$file" 2>/dev/null | while IFS=: read -r line_num comment; do \
				comment_text=$$(echo "$$comment" | sed 's|^\s*//\s*||'); \
				if echo "$$comment_text" | grep -qP '[\x{4e00}-\x{9fff}]' 2>/dev/null; then \
					echo "    $(RED)Line $$line_num: Contains Chinese characters$(RESET)"; \
					echo "    Content: $$comment_text"; \
				fi; \
			done; \
		done; \
	else \
		echo "$(BLUE)Skipping TypeScript comment check (no TypeScript project)$(RESET)"; \
	fi

# =============================================================================
# Integration with existing workflows
# =============================================================================

# Add comment check to smart check workflow
smart_check_with_comments: smart_check check-comments ## Smart check including comment language verification

# Add comment check to CI workflow
smart_ci_with_comments: smart_format smart_check check-comments smart_test smart_build ## Full CI with comment checks

# =============================================================================
# Help and Info
# =============================================================================

info-comment-check: ## Show comment checking information
	@echo "$(BLUE)Comment Language Check Information:$(RESET)"
	@echo "  Script location: $(COMMENT_CHECK_SCRIPT)"
	@if [ -f "$(COMMENT_CHECK_SCRIPT)" ]; then \
		echo "  Status: $(GREEN)Available$(RESET)"; \
	else \
		echo "  Status: $(RED)Missing$(RESET)"; \
	fi
	@echo "  Supported languages: Go, Java, Python, TypeScript"
	@echo "  Rule: All comments must be written in English"
	@echo ""
	@echo "$(YELLOW)Available commands:$(RESET)"
	@echo "  make check-comments           - Check all supported files"
	@echo "  make check-comments-go        - Check only Go files"
	@echo "  make check-comments-java      - Check only Java files"
	@echo "  make check-comments-python    - Check only Python files"
	@echo "  make check-comments-typescript - Check only TypeScript files"
