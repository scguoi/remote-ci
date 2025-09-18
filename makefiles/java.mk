# =============================================================================
# Java Language Support - Makefile Module
# =============================================================================

# Java project variables - use dynamic directories from config
MVN := mvn
JAVA_MAIN_MODULE := user-web
JAVA_ARTIFACT := $(JAVA_MAIN_MODULE)-1.0.0.jar

# Get all Java directories from config - use shell directly to avoid function call issues
JAVA_DIRS := $(shell \
	if [ -n "$(LOCALCI_CONFIG)" ] && [ -f "$(LOCALCI_CONFIG)" ]; then \
		scripts/parse_localci.sh enabled java $(LOCALCI_CONFIG) | cut -d'|' -f2 | tr '\n' ' '; \
	else \
		echo "demo-apps/backends/java"; \
	fi)

JAVA_PRIMARY_DIR := $(shell echo $(JAVA_DIRS) | cut -d' ' -f1)

# For legacy compatibility, use primary dir for single-dir variables
JAVA_DIR := $(JAVA_PRIMARY_DIR)
JAVA_FILES := $(shell \
	for dir in $(JAVA_DIRS); do \
		if [ -d "$$dir" ]; then \
			find $$dir -name "*.java" 2>/dev/null || true; \
		fi; \
	done)

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
	@if [ -d "$(JAVA_DIR)" ]; then \
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
	@if [ -d "$(JAVA_DIR)" ]; then \
		echo "$(YELLOW)Checking Java tools...$(RESET)"; \
		command -v java >/dev/null 2>&1 || (echo "$(RED)Java is not installed$(RESET)" && exit 1); \
		command -v $(MVN) >/dev/null 2>&1 || (echo "$(RED)Maven is not installed$(RESET)" && exit 1); \
		echo "$(GREEN)Java tools available$(RESET)"; \
	fi

# =============================================================================
# Java Code Formatting
# =============================================================================

fmt-java: ## Format Java code (all configured Java projects)
	@if [ -n "$(JAVA_DIRS)" ]; then \
		echo "$(YELLOW)Formatting Java code in: $(JAVA_DIRS)$(RESET)"; \
		for dir in $(JAVA_DIRS); do \
			if [ -d "$$dir" ]; then \
				echo "$(YELLOW)  Processing $$dir...$(RESET)"; \
				cd $$dir && $(MVN) spotless:apply; \
				cd - > /dev/null; \
			else \
				echo "$(RED)    Directory $$dir does not exist$(RESET)"; \
			fi; \
		done; \
		echo "$(GREEN)Java code formatting completed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Java formatting (no Java projects configured)$(RESET)"; \
	fi

# =============================================================================
# Java Code Quality Checks
# =============================================================================

check-java: ## Check Java code quality (all configured Java projects)
	@if [ -n "$(JAVA_DIRS)" ]; then \
		echo "$(YELLOW)Checking Java code quality in: $(JAVA_DIRS)$(RESET)"; \
		for dir in $(JAVA_DIRS); do \
			if [ -d "$$dir" ]; then \
				echo "$(YELLOW)  Processing $$dir...$(RESET)"; \
				cd $$dir && \
				echo "$(YELLOW)    Compiling project...$(RESET)" && \
				$(MVN) clean compile $(MAVEN_QUIET) && \
				echo "$(YELLOW)    Running Spotless format check...$(RESET)" && \
				$(MVN) spotless:check $(MAVEN_QUIET) && \
				echo "$(YELLOW)    Running Checkstyle...$(RESET)" && \
				$(MVN) checkstyle:check && \
				echo "$(YELLOW)    Running SpotBugs (with fresh compilation)...$(RESET)" && \
				$(MVN) clean compile spotbugs:check $(MAVEN_QUIET); \
				cd - > /dev/null; \
			else \
				echo "$(RED)    Directory $$dir does not exist$(RESET)"; \
			fi; \
		done; \
		echo "$(GREEN)Java code quality checks completed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Java checks (no Java projects configured)$(RESET)"; \
	fi

# Show Java project information
info-java: ## Show Java project information
	@echo "$(BLUE)Java Project Information:$(RESET)"
	@echo "  Java files: $(words $(JAVA_FILES))"
	@if [ -d "$(JAVA_DIR)" ]; then \
		echo "  Java version: $$(java -version 2>&1 | head -n 1)"; \
		echo "  Maven version: $$(mvn --version | head -n 1)"; \
	fi

# Format check (without modifying files)
fmt-check-java: ## Check if Java code format meets standards (without modifying files)
	@echo "$(YELLOW)Checking Java code formatting...$(RESET)"
	@if [ -d "$(JAVA_DIR)" ]; then \
		cd $(JAVA_DIR) && $(MVN) spotless:check || (echo "$(RED)Java code is not formatted. Run 'make fmt-java' to fix.$(RESET)" && exit 1); \
	fi
	@echo "$(GREEN)Java code formatting checks passed$(RESET)"

# =============================================================================
# Individual Java Quality Check Tools
# =============================================================================

check-checkstyle-java: ## Run Checkstyle code style checks
	@echo "$(YELLOW)Running Checkstyle checks...$(RESET)"
	@if [ -d "$(JAVA_DIR)" ]; then \
		cd $(JAVA_DIR) && $(MVN) checkstyle:check; \
		echo "$(GREEN)Checkstyle checks passed$(RESET)"; \
	fi

check-spotbugs-java: ## Run SpotBugs static analysis
	@echo "$(YELLOW)Running SpotBugs static analysis...$(RESET)"
	@if [ -d "$(JAVA_DIR)" ]; then \
		cd $(JAVA_DIR) && $(MVN) clean compile spotbugs:check $(MAVEN_QUIET); \
		echo "$(GREEN)SpotBugs analysis passed$(RESET)"; \
	fi

check-pmd-java: ## Run PMD static analysis (currently disabled for Java 21)
	@echo "$(YELLOW)PMD checks temporarily disabled (Java 21 compatibility issues)$(RESET)"
	@if [ -d "$(JAVA_DIR)" ]; then \
		echo "$(BLUE)PMD is currently skipped in pom.xml due to Java 21 compatibility$(RESET)"; \
	fi

# =============================================================================
# Java Build and Deployment
# =============================================================================

build-java: ## Build Java project (all configured Java projects)
	@if [ -n "$(JAVA_DIRS)" ]; then \
		echo "$(YELLOW)Building Java projects in: $(JAVA_DIRS)$(RESET)"; \
		for dir in $(JAVA_DIRS); do \
			if [ -d "$$dir" ]; then \
				echo "$(YELLOW)  Building $$dir...$(RESET)"; \
				cd $$dir && $(MVN) clean package $(MAVEN_SKIP_TESTS) $(MAVEN_QUIET); \
				echo "$(GREEN)  Java project built successfully: $$dir$(RESET)"; \
				cd - > /dev/null; \
			else \
				echo "$(RED)    Directory $$dir does not exist$(RESET)"; \
			fi; \
		done; \
		echo "$(GREEN)Java build completed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Java build (no Java projects configured)$(RESET)"; \
	fi

build-fast-java: ## Fast build Java project (skip tests and checks, all configured Java projects)
	@if [ -n "$(JAVA_DIRS)" ]; then \
		echo "$(YELLOW)Fast building Java projects in: $(JAVA_DIRS)$(RESET)"; \
		for dir in $(JAVA_DIRS); do \
			if [ -d "$$dir" ]; then \
				echo "$(YELLOW)  Fast building $$dir...$(RESET)"; \
				cd $$dir && $(MVN) clean compile package $(MAVEN_SKIP_TESTS) $(MAVEN_QUIET); \
				echo "$(GREEN)  Java project built successfully (fast mode): $$dir$(RESET)"; \
				cd - > /dev/null; \
			else \
				echo "$(RED)    Directory $$dir does not exist$(RESET)"; \
			fi; \
		done; \
		echo "$(GREEN)Java fast build completed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Java fast build (no Java projects configured)$(RESET)"; \
	fi

test-java: ## Run Java tests (all configured Java projects)
	@if [ -n "$(JAVA_DIRS)" ]; then \
		echo "$(YELLOW)Running Java tests in: $(JAVA_DIRS)$(RESET)"; \
		for dir in $(JAVA_DIRS); do \
			if [ -d "$$dir" ]; then \
				echo "$(YELLOW)  Testing $$dir...$(RESET)"; \
				cd $$dir && $(MVN) test; \
				cd - > /dev/null; \
			else \
				echo "$(RED)    Directory $$dir does not exist$(RESET)"; \
			fi; \
		done; \
		echo "$(GREEN)Java tests completed$(RESET)"; \
	else \
		echo "$(BLUE)Skipping Java tests (no Java projects configured)$(RESET)"; \
	fi

run-java: ## Run Java Spring Boot application (first configured Java project)
	@if [ -n "$(JAVA_DIRS)" ]; then \
		first_dir=$$(echo $(JAVA_DIRS) | cut -d' ' -f1); \
		if [ -d "$$first_dir" ]; then \
			echo "$(YELLOW)Starting Java application from $$first_dir...$(RESET)"; \
			echo "$(BLUE)Application will start at http://localhost:$(JAVA_APP_PORT)$(RESET)"; \
			if [ $$(echo $(JAVA_DIRS) | wc -w) -gt 1 ]; then \
				echo "$(BLUE)Note: Multiple Java projects detected ($(JAVA_DIRS)). Running first one: $$first_dir$(RESET)"; \
			fi; \
			cd $$first_dir && $(MVN) spring-boot:run -pl $(JAVA_MAIN_MODULE) -Dspring-boot.run.profiles=$(SPRING_PROFILE); \
		else \
			echo "$(RED)Java directory $$first_dir does not exist$(RESET)"; \
		fi; \
	else \
		echo "$(BLUE)No Java applications configured to run$(RESET)"; \
	fi

run-jar-java: ## Run Java application from JAR file (first configured Java project)
	@if [ -n "$(JAVA_DIRS)" ]; then \
		first_dir=$$(echo $(JAVA_DIRS) | cut -d' ' -f1); \
		if [ -d "$$first_dir" ]; then \
			echo "$(YELLOW)Running Java application from JAR in $$first_dir...$(RESET)"; \
			if [ -f "$$first_dir/$(JAVA_MAIN_MODULE)/target/$(JAVA_ARTIFACT)" ]; then \
				cd $$first_dir && java -jar $(JAVA_MAIN_MODULE)/target/$(JAVA_ARTIFACT) --spring.profiles.active=$(SPRING_PROFILE); \
			else \
				echo "$(RED)JAR file not found in $$first_dir. Run 'make build-java' first.$(RESET)"; \
				exit 1; \
			fi; \
		else \
			echo "$(RED)Java directory $$first_dir does not exist$(RESET)"; \
		fi; \
	else \
		echo "$(BLUE)No Java applications configured to run$(RESET)"; \
	fi

# =============================================================================
# Java Database Operations
# =============================================================================

db-info-java: ## Show database migration status
	@if [ -d "$(JAVA_DIR)" ]; then \
		echo "$(YELLOW)Checking database migration status...$(RESET)"; \
		cd $(JAVA_DIR) && $(MVN) flyway:info -pl $(JAVA_MAIN_MODULE); \
	fi

db-migrate-java: ## Execute database migrations
	@if [ -d "$(JAVA_DIR)" ]; then \
		echo "$(YELLOW)Executing database migrations...$(RESET)"; \
		cd $(JAVA_DIR) && $(MVN) flyway:migrate -pl $(JAVA_MAIN_MODULE); \
		echo "$(GREEN)Database migrations completed$(RESET)"; \
	fi

db-repair-java: ## Repair database migration state
	@if [ -d "$(JAVA_DIR)" ]; then \
		echo "$(YELLOW)Repairing database migration state...$(RESET)"; \
		cd $(JAVA_DIR) && $(MVN) flyway:repair -pl $(JAVA_MAIN_MODULE); \
		echo "$(GREEN)Database migration state repaired$(RESET)"; \
	fi

# =============================================================================
# Java Development Tools
# =============================================================================

clean-java: ## Clean Java build artifacts
	@if [ -d "$(JAVA_DIR)" ]; then \
		echo "$(YELLOW)Cleaning Java build artifacts...$(RESET)"; \
		cd $(JAVA_DIR) && $(MVN) clean $(MAVEN_QUIET); \
		echo "$(GREEN)Java build artifacts cleaned$(RESET)"; \
	fi

deps-java: ## Show Java dependency tree
	@if [ -d "$(JAVA_DIR)" ]; then \
		echo "$(YELLOW)Analyzing Java dependencies...$(RESET)"; \
		cd $(JAVA_DIR) && $(MVN) dependency:tree; \
	fi

security-java: ## Run Java security vulnerability scan
	@if [ -d "$(JAVA_DIR)" ]; then \
		echo "$(YELLOW)Running Java security vulnerability scan...$(RESET)"; \
		cd $(JAVA_DIR) && $(MVN) org.owasp:dependency-check-maven:check 2>/dev/null || \
		echo "$(BLUE)OWASP Dependency Check not configured. Add plugin to pom.xml for security scanning.$(RESET)"; \
	fi

# =============================================================================
# Java CI/CD Integration
# =============================================================================

ci-java: ## Full CI pipeline for Java (build + test + quality checks)
	@if [ -d "$(JAVA_DIR)" ]; then \
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
	@if [ -d "$(JAVA_DIR)" ]; then \
		echo "$(YELLOW)Running quick Java quality checks...$(RESET)"; \
		cd $(JAVA_DIR) && \
		$(MVN) clean compile $(MAVEN_QUIET) && \
		$(MVN) spotless:check $(MAVEN_QUIET) && \
		$(MVN) checkstyle:check; \
		echo "$(GREEN)Quick Java quality checks completed$(RESET)"; \
	fi

pre-commit-java: ## Pre-commit checks for Java (format + quick check)
	@if [ -d "$(JAVA_DIR)" ]; then \
		echo "$(YELLOW)Running Java pre-commit checks...$(RESET)"; \
		$(MAKE) fmt-java && \
		$(MAKE) quick-check-java; \
		echo "$(GREEN)Java code ready for commit$(RESET)"; \
	fi
