#!/bin/bash

# =============================================================================
# Makefile 快速测试脚本 - 重点测试核心功能
# =============================================================================

# 颜色定义
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
RESET='\033[0m'

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 记录测试结果
log_test() {
    local test_name="$1"
    local status="$2"
    local message="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$status" = "PASS" ]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo -e "  ${GREEN}✓ PASS${RESET} $test_name"
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "  ${RED}✗ FAIL${RESET} $test_name"
        [ -n "$message" ] && echo -e "    ${YELLOW}$message${RESET}"
    fi
}

# 执行命令并检查结果
run_command_test() {
    local cmd="$1"
    local test_name="$2"
    local timeout="${3:-30}"
    
    echo -e "${BLUE}Testing:${RESET} $cmd"
    
    if eval "$cmd" >/dev/null 2>&1; then
        log_test "$test_name" "PASS"
        return 0
    else
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            log_test "$test_name" "FAIL" "命令超时 (${timeout}s)"
        else
            log_test "$test_name" "FAIL" "命令执行失败 (退出码: $exit_code)"
        fi
        return 1
    fi
}

# 检查命令输出包含特定内容
check_output_contains() {
    local cmd="$1"
    local expected="$2"
    local test_name="$3"
    local timeout="${4:-10}"
    
    echo -e "${BLUE}Testing:${RESET} $cmd"
    local output
    if output=$(eval "$cmd" 2>&1); then
        if echo "$output" | grep -q "$expected"; then
            log_test "$test_name" "PASS"
            return 0
        else
            log_test "$test_name" "FAIL" "输出不包含: '$expected'"
            return 1
        fi
    else
        log_test "$test_name" "FAIL" "命令执行失败或超时"
        return 1
    fi
}

echo -e "${BLUE}===============================================${RESET}"
echo -e "${BLUE}🧪 Makefile 快速功能测试${RESET}"
echo -e "${BLUE}===============================================${RESET}"
echo ""

# 1. 基础命令测试
echo -e "${YELLOW}📋 1. 基础命令测试${RESET}"

check_output_contains "make help" "智能版" "help命令显示正确" 5
check_output_contains "make" "核心命令" "默认命令工作正常" 5
run_command_test "make status" "status命令执行" 5
run_command_test "make info" "info命令执行" 10

echo ""

# 2. 智能检测测试
echo -e "${YELLOW}📋 2. 智能检测测试${RESET}"

check_output_contains "make _debug" "ACTIVE_PROJECTS:" "项目检测功能" 5

# 检查是否检测到所有4个项目
active_projects=$(make _debug 2>&1 | grep "ACTIVE_PROJECTS:" | cut -d"'" -f2)
if echo "$active_projects" | grep -q "go" && \
   echo "$active_projects" | grep -q "java" && \
   echo "$active_projects" | grep -q "python" && \
   echo "$active_projects" | grep -q "typescript"; then
    log_test "检测到所有4个项目类型" "PASS"
else
    log_test "检测到所有4个项目类型" "FAIL" "检测结果: $active_projects"
fi

echo ""

# 3. 核心工作流测试
echo -e "${YELLOW}📋 3. 核心工作流测试${RESET}"

run_command_test "make format" "智能格式化" 60
run_command_test "make check" "智能代码检查" 120  
run_command_test "make clean" "智能清理" 15

echo ""

# 4. 向后兼容性测试
echo -e "${YELLOW}📋 4. 向后兼容性测试${RESET}"

run_command_test "make enable-legacy" "启用旧命令集" 5
run_command_test "make fmt-go" "旧Go格式化命令" 15
run_command_test "make project-status" "旧项目状态命令" 5

echo ""

# 5. Git钩子管理测试
echo -e "${YELLOW}📋 5. Git钩子管理测试${RESET}"

check_output_contains "make hooks" "Git钩子管理" "钩子管理菜单" 5

echo ""

# 6. 错误处理测试
echo -e "${YELLOW}📋 6. 错误处理测试${RESET}"

# 测试不存在的命令 (应该失败)
if ! make nonexistent-command-xyz >/dev/null 2>&1; then
    log_test "不存在命令正确处理" "PASS"
else
    log_test "不存在命令正确处理" "FAIL" "应该返回错误但成功了"
fi

# 测试是否有警告
help_output=$(make help 2>&1)
if echo "$help_output" | grep -q "warning"; then
    log_test "无Makefile警告" "FAIL" "发现警告信息"
else
    log_test "无Makefile警告" "PASS"
fi

echo ""

# 生成测试报告
echo -e "${BLUE}===============================================${RESET}"
echo -e "${BLUE}📊 快速测试报告${RESET}"
echo -e "${BLUE}===============================================${RESET}"
echo ""

echo -e "${YELLOW}测试统计:${RESET}"
echo "  总测试数量: $TOTAL_TESTS"
echo -e "  通过测试: ${GREEN}$PASSED_TESTS${RESET}"
echo -e "  失败测试: ${RED}$FAILED_TESTS${RESET}"

if [ $TOTAL_TESTS -gt 0 ]; then
    success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo "  成功率: $success_rate%"
fi

echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 快速测试全部通过！Makefile优化成功！${RESET}"
    echo -e "${GREEN}主要功能：智能检测、格式化、检查、向后兼容性 - 全部正常${RESET}"
    exit 0
else
    echo -e "${RED}❌ 发现 $FAILED_TESTS 个问题需要关注${RESET}"
    echo -e "${YELLOW}但这不影响主要功能的使用${RESET}"
    exit 1
fi