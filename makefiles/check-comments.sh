#!/bin/bash

# =============================================================================
# Comment Language Checker - English Comments Enforcement
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Configuration
TEMP_DIR="/tmp/comment-check-$$"
COMMENTS_FILE="$TEMP_DIR/comments.txt"
ERRORS_FILE="$TEMP_DIR/errors.txt"
WARNINGS_FILE="$TEMP_DIR/warnings.txt"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR" 2>/dev/null || true
}
trap cleanup EXIT

# Function to extract comments from different file types
extract_comments() {
    local file="$1"
    local ext="${file##*.}"

    case "$ext" in
        "go")
            # Extract Go comments (// and /* */)
            grep -n '^\s*//\|^\s*/\*\|^\s*\*' "$file" | sed 's/^\([0-9]*\):\s*\/\/\s*/\1: /' | sed 's/^\([0-9]*\):\s*\/\*\s*/\1: /' | sed 's/^\([0-9]*\):\s*\*\s*/\1: /' || true
            ;;
        "java")
            # Extract Java comments (// and /* */ and javadoc /** */)
            grep -n '^\s*//\|^\s*/\*\|^\s*\*' "$file" | sed 's/^\([0-9]*\):\s*\/\/\s*/\1: /' | sed 's/^\([0-9]*\):\s*\/\*\s*/\1: /' | sed 's/^\([0-9]*\):\s*\*\s*/\1: /' || true
            ;;
        "py")
            # Extract Python comments (# and """ docstrings)
            grep -n '^\s*#\|^\s*"""' "$file" | sed 's/^\([0-9]*\):\s*#\s*/\1: /' | sed 's/^\([0-9]*\):\s*"""\s*/\1: /' || true
            ;;
        "ts"|"tsx"|"js"|"jsx")
            # Extract TypeScript/JavaScript comments (// and /* */)
            grep -n '^\s*//\|^\s*/\*\|^\s*\*' "$file" | sed 's/^\([0-9]*\):\s*\/\/\s*/\1: /' | sed 's/^\([0-9]*\):\s*\/\*\s*/\1: /' | sed 's/^\([0-9]*\):\s*\*\s*/\1: /' || true
            ;;
        *)
            echo "Unsupported file type: $ext" >&2
            return 1
            ;;
    esac
}

# Function to check if text contains Chinese characters
contains_chinese() {
    local text="$1"
    # Check for Chinese characters (Unicode ranges)
    echo "$text" | grep -qP '[\x{4e00}-\x{9fff}]' 2>/dev/null
}

# Function to check comments in a single file
check_file_comments() {
    local file="$1"
    local violations=0

    echo -e "${YELLOW}Checking comments in: $file${RESET}"

    # Extract comments
    local comments
    comments=$(extract_comments "$file")

    if [ -z "$comments" ]; then
        echo "  No comments found"
        return 0
    fi

    # Check each comment line
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            local line_num=$(echo "$line" | cut -d: -f1)
            local comment_text=$(echo "$line" | cut -d: -f2-)

            # Skip empty comments or just punctuation
            local cleaned_text=$(echo "$comment_text" | sed 's/[[:punct:][:space:]]//g')
            if [ -z "$cleaned_text" ]; then
                continue
            fi

            # Check for Chinese characters
            if contains_chinese "$comment_text"; then
                echo -e "  ${RED}Line $line_num: Contains non-English characters${RESET}"
                echo "    Content: $comment_text"
                violations=$((violations + 1))
            fi
        fi
    done <<< "$comments"

    return $violations
}

# Main function
main() {
    echo -e "${BLUE}Comment Language Checker - Enforcing English Comments${RESET}"
    echo ""

    local total_violations=0
    local files_checked=0

    # Find all relevant source files
    local source_files=()

    # Go files
    if [ -d "backend-go" ]; then
        while IFS= read -r -d '' file; do
            source_files+=("$file")
        done < <(find backend-go -name "*.go" -print0 2>/dev/null || true)
    fi

    # Java files
    if [ -d "backend-java" ]; then
        while IFS= read -r -d '' file; do
            source_files+=("$file")
        done < <(find backend-java -name "*.java" -print0 2>/dev/null || true)
    fi

    # Python files
    if [ -d "backend-python" ]; then
        while IFS= read -r -d '' file; do
            source_files+=("$file")
        done < <(find backend-python -name "*.py" -print0 2>/dev/null || true)
    fi

    # TypeScript files
    if [ -d "frontend-ts" ]; then
        while IFS= read -r -d '' file; do
            source_files+=("$file")
        done < <(find frontend-ts -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | grep -v node_modules | head -20 | tr '\n' '\0' || true)
    fi

    if [ ${#source_files[@]} -eq 0 ]; then
        echo -e "${YELLOW}No source files found to check${RESET}"
        exit 0
    fi

    echo "Found ${#source_files[@]} files to check"
    echo ""

    # Check each file
    for file in "${source_files[@]}"; do
        if [ -f "$file" ]; then
            check_file_comments "$file"
            local file_violations=$?
            total_violations=$((total_violations + file_violations))
            files_checked=$((files_checked + 1))
            echo ""
        fi
    done

    # Summary
    echo -e "${BLUE}Comment Language Check Summary:${RESET}"
    echo "  Files checked: $files_checked"
    echo "  Total violations: $total_violations"

    if [ $total_violations -eq 0 ]; then
        echo -e "${GREEN}✅ All comments are in English!${RESET}"
        exit 0
    else
        echo -e "${RED}❌ Found $total_violations non-English comments${RESET}"
        echo -e "${YELLOW}Please update comments to use English only${RESET}"
        exit 1
    fi
}

# Help function
show_help() {
    echo "Comment Language Checker"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "This script checks that all comments in source code are written in English."
    echo "Supported file types: .go, .java, .py, .ts, .tsx, .js, .jsx"
}

# Parse arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac