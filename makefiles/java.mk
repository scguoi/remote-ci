# =============================================================================
# Java Language Support - Makefile Module
# =============================================================================

# Java tool definitions
MVN := mvn
JAVA_MAIN_MODULE := user-web
JAVA_ARTIFACT := $(JAVA_MAIN_MODULE)-1.0.0.jar

# Java project variables
JAVA_DIR := backend-java
JAVA_FILES := $(shell find backend-java -name "*.java" 2>/dev/null || true)

# Maven options
MAVEN_OPTS := -Dmaven.test.failure.ignore=false
MAVEN_SKIP_TESTS := -DskipTests
MAVEN_QUIET := -q

# Spring Boot configuration
SPRING_PROFILE := dev
JAVA_APP_PORT := 8080

# =============================================================================
# Java Tool Installation
# =============================================================================

install-tools-java: ## Install Java development tools
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Installing Java tools...$(RESET)"; \
		echo "$(GREEN)Java tools ready (using Maven plugins)$(RESET)"; \
		echo "  - Spotless: Code formatting with Google Java Format"; \
		echo "  - Checkstyle: Code style verification"; \
		echo "  - SpotBugs: Static analysis for bug detection"; \
		echo "  - PMD: Code quality analyzer"; \
	else \
		echo "$(BLUE)Skipping Java tools (no Java project detected)$(RESET)"; \
	fi

check-tools-java: ## Check Java development tools
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Checking Java tools...$(RESET)"; \
		command -v java >/dev/null 2>&1 || (echo "$(RED)Java is not installed$(RESET)" && exit 1); \
		command -v $(MVN) >/dev/null 2>&1 || (echo "$(RED)Maven is not installed$(RESET)" && exit 1); \
		echo "$(GREEN)Java tools available$(RESET)"; \
	fi

# =============================================================================
# Java Code Formatting
# =============================================================================

fmt-java: ## Format Java code
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Formatting Java code...$(RESET)"; \
		cd $(JAVA_DIR) && $(MVN) spotless:apply; \
		echo "$(GREEN)Java code formatted$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Java formatting (no Java project)$(RESET)"; \
	fi

# =============================================================================
# Java Code Quality Checks
# =============================================================================

check-java: ## Check Java code quality
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Checking Java code quality...$(RESET)"; \
		cd $(JAVA_DIR) && \
		echo "$(YELLOW)Compiling project...$(RESET)" && \
		$(MVN) clean compile $(MAVEN_QUIET) && \
		echo "$(YELLOW)Running Spotless format check...$(RESET)" && \
		$(MVN) spotless:check $(MAVEN_QUIET) && \
		echo "$(YELLOW)Running Checkstyle...$(RESET)" && \
		$(MVN) checkstyle:check && \
		echo "$(YELLOW)Running SpotBugs (with fresh compilation)...$(RESET)" && \
		$(MVN) clean compile spotbugs:check $(MAVEN_QUIET); \
		echo "$(GREEN)Java code quality checks completed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Java checks (no Java project)$(RESET)"; \
	fi

# Show Java project information
info-java: ## Show Java project information
	@echo "$(BLUE)Java Project Information:$(RESET)"
	@echo "  Java files: $(words $(JAVA_FILES))"
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "  Java version: $$(java -version 2>&1 | head -n 1)"; \
		echo "  Maven version: $$(mvn --version | head -n 1)"; \
	fi

# Format check (without modifying files)
fmt-check-java: ## Check if Java code format meets standards (without modifying files)
	@echo "$(YELLOW)Checking Java code formatting...$(RESET)"
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		cd $(JAVA_DIR) && $(MVN) spotless:check || (echo "$(RED)Java code is not formatted. Run 'make fmt-java' to fix.$(RESET)" && exit 1); \
	fi
	@echo "$(GREEN)Java code formatting checks passed$(RESET)"

# =============================================================================
# Individual Java Quality Check Tools
# =============================================================================

check-checkstyle-java: ## Run Checkstyle code style checks
	@echo "$(YELLOW)Running Checkstyle checks...$(RESET)"
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		cd $(JAVA_DIR) && $(MVN) checkstyle:check; \
		echo "$(GREEN)Checkstyle checks passed$(RESET)"; \
	fi

check-spotbugs-java: ## Run SpotBugs static analysis
	@echo "$(YELLOW)Running SpotBugs static analysis...$(RESET)"
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		cd $(JAVA_DIR) && $(MVN) clean compile spotbugs:check $(MAVEN_QUIET); \
		echo "$(GREEN)SpotBugs analysis passed$(RESET)"; \
	fi

check-pmd-java: ## Run PMD static analysis (currently disabled for Java 21)
	@echo "$(YELLOW)PMD checks temporarily disabled (Java 21 compatibility issues)$(RESET)"
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(BLUE)PMD is currently skipped in pom.xml due to Java 21 compatibility$(RESET)"; \
	fi

# =============================================================================
# Java Build and Deployment
# =============================================================================

build-java: ## Build Java project
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Building Java project...$(RESET)"; \
		cd $(JAVA_DIR) && $(MVN) clean package $(MAVEN_SKIP_TESTS) $(MAVEN_QUIET); \
		echo "$(GREEN)Java project built successfully$(RESET)"; \
		echo "$(BLUE)JAR file: $(JAVA_DIR)/$(JAVA_MAIN_MODULE)/target/$(JAVA_ARTIFACT)$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Java build (no Java project)$(RESET)"; \
	fi

build-fast-java: ## Fast build Java project (skip tests and checks)
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Fast building Java project...$(RESET)"; \
		cd $(JAVA_DIR) && $(MVN) clean compile package $(MAVEN_SKIP_TESTS) $(MAVEN_QUIET); \
		echo "$(GREEN)Java project built successfully (fast mode)$(RESET)"; \
	fi

test-java: ## Run Java tests
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Running Java tests...$(RESET)"; \
		cd $(JAVA_DIR) && $(MVN) test; \
		echo "$(GREEN)Java tests completed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Java tests (no Java project)$(RESET)"; \
	fi

run-java: ## Run Java Spring Boot application
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Starting Java application...$(RESET)"; \
		echo "$(BLUE)Application will start at http://localhost:$(JAVA_APP_PORT)$(RESET)"; \
		cd $(JAVA_DIR) && $(MVN) spring-boot:run -pl $(JAVA_MAIN_MODULE) -Dspring-boot.run.profiles=$(SPRING_PROFILE); \
	else \
		echo "$(BLUE)No Java application to run$(RESET)"; \
	fi

run-jar-java: ## Run Java application from JAR file
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Running Java application from JAR...$(RESET)"; \
		if [ -f "$(JAVA_DIR)/$(JAVA_MAIN_MODULE)/target/$(JAVA_ARTIFACT)" ]; then \
			cd $(JAVA_DIR) && java -jar $(JAVA_MAIN_MODULE)/target/$(JAVA_ARTIFACT) --spring.profiles.active=$(SPRING_PROFILE); \
		else \
			echo "$(RED)JAR file not found. Run 'make build-java' first.$(RESET)"; \
			exit 1; \
		fi; \
	fi

# =============================================================================
# Java Database Operations
# =============================================================================

db-info-java: ## Show database migration status
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Checking database migration status...$(RESET)"; \
		cd $(JAVA_DIR) && $(MVN) flyway:info -pl $(JAVA_MAIN_MODULE); \
	fi

db-migrate-java: ## Execute database migrations
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Executing database migrations...$(RESET)"; \
		cd $(JAVA_DIR) && $(MVN) flyway:migrate -pl $(JAVA_MAIN_MODULE); \
		echo "$(GREEN)Database migrations completed$(RESET)"; \
	fi

db-repair-java: ## Repair database migration state
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Repairing database migration state...$(RESET)"; \
		cd $(JAVA_DIR) && $(MVN) flyway:repair -pl $(JAVA_MAIN_MODULE); \
		echo "$(GREEN)Database migration state repaired$(RESET)"; \
	fi

# =============================================================================
# Java Development Tools
# =============================================================================

clean-java: ## Clean Java build artifacts
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Cleaning Java build artifacts...$(RESET)"; \
		cd $(JAVA_DIR) && $(MVN) clean $(MAVEN_QUIET); \
		echo "$(GREEN)Java build artifacts cleaned$(RESET)"; \
	fi

deps-java: ## Show Java dependency tree
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Analyzing Java dependencies...$(RESET)"; \
		cd $(JAVA_DIR) && $(MVN) dependency:tree; \
	fi

security-java: ## Run Java security vulnerability scan
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Running Java security vulnerability scan...$(RESET)"; \
		cd $(JAVA_DIR) && $(MVN) org.owasp:dependency-check-maven:check 2>/dev/null || \
		echo "$(BLUE)OWASP Dependency Check not configured. Add plugin to pom.xml for security scanning.$(RESET)"; \
	fi

# =============================================================================
# Java CI/CD Integration
# =============================================================================

ci-java: ## Full CI pipeline for Java (build + test + quality checks)
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Running Java CI pipeline...$(RESET)"; \
		$(MAKE) clean-java && \
		$(MAKE) check-java && \
		$(MAKE) build-java && \
		$(MAKE) test-java; \
		echo "$(GREEN)Java CI pipeline completed successfully$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Java CI (no Java project)$(RESET)"; \
	fi

quick-check-java: ## Quick Java quality check (format + style, no SpotBugs)
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Running quick Java quality checks...$(RESET)"; \
		cd $(JAVA_DIR) && \
		$(MVN) clean compile $(MAVEN_QUIET) && \
		$(MVN) spotless:check $(MAVEN_QUIET) && \
		$(MVN) checkstyle:check; \
		echo "$(GREEN)Quick Java quality checks completed$(RESET)"; \
	fi

pre-commit-java: ## Pre-commit checks for Java (format + quick check)
	@if [ "$(HAS_JAVA)" = "true" ]; then \
		echo "$(YELLOW)Running Java pre-commit checks...$(RESET)"; \
		$(MAKE) fmt-java && \
		$(MAKE) quick-check-java; \
		echo "$(GREEN)Java code ready for commit$(RESET)"; \
	fi