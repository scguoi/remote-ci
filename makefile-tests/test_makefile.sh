#!/bin/bash

# =============================================================================
# Makefile 全面测试脚本
# 测试优化后的智能Makefile的所有功能
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
TEST_RESULTS=()

# 记录测试结果
log_test() {
    local test_name="$1"
    local status="$2"
    local message="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$status" = "PASS" ]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo -e "  ${GREEN}✓ PASS${RESET} $test_name"
        TEST_RESULTS+=("PASS: $test_name")
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "  ${RED}✗ FAIL${RESET} $test_name"
        [ -n "$message" ] && echo -e "    ${YELLOW}$message${RESET}"
        TEST_RESULTS+=("FAIL: $test_name - $message")
    fi
}

# 执行命令并检查结果
run_command() {
    local cmd="$1"
    local test_name="$2"
    local expect_success="${3:-true}"
    
    echo -e "${BLUE}Running:${RESET} $cmd"
    
    if [ "$expect_success" = "true" ]; then
        if $cmd >/dev/null 2>&1; then
            log_test "$test_name" "PASS"
            return 0
        else
            log_test "$test_name" "FAIL" "命令执行失败"
            return 1
        fi
    else
        if ! $cmd >/dev/null 2>&1; then
            log_test "$test_name" "PASS"
            return 0
        else
            log_test "$test_name" "FAIL" "命令应该失败但成功了"
            return 1
        fi
    fi
}

# 检查命令输出包含特定内容
check_output_contains() {
    local cmd="$1"
    local expected="$2"
    local test_name="$3"
    
    echo -e "${BLUE}Running:${RESET} $cmd"
    local output=$($cmd 2>&1)
    
    if echo "$output" | grep -q "$expected"; then
        log_test "$test_name" "PASS"
        return 0
    else
        log_test "$test_name" "FAIL" "输出不包含: '$expected'"
        echo -e "${YELLOW}实际输出:${RESET}"
        echo "$output" | head -5
        return 1
    fi
}

# 检查命令是否存在
command_exists() {
    local cmd="$1"
    local test_name="$2"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        log_test "$test_name" "PASS"
        return 0
    else
        log_test "$test_name" "FAIL" "命令 '$cmd' 不存在"
        return 1
    fi
}

# 主测试函数
main() {
    echo -e "${BLUE}==============================================================================${RESET}"
    echo -e "${BLUE}🧪 Makefile 全面测试开始${RESET}"
    echo -e "${BLUE}==============================================================================${RESET}"
    echo ""
    
    # 1. 基础环境检查
    echo -e "${YELLOW}📋 1. 基础环境检查${RESET}"
    command_exists "make" "make命令存在"
    
    if [ -f "Makefile" ]; then
        log_test "Makefile文件存在" "PASS"
    else
        log_test "Makefile文件存在" "FAIL" "找不到Makefile文件"
        return 1
    fi
    
    if [ -d "makefiles/core" ]; then
        log_test "核心模块目录存在" "PASS"
    else
        log_test "核心模块目录存在" "FAIL"
    fi
    
    echo ""
    
    # 2. 核心命令基本功能测试
    echo -e "${YELLOW}📋 2. 核心命令基本功能测试${RESET}"
    
    # help命令
    check_output_contains "make help" "多语言CI/CD工具链" "help命令显示正确标题"
    check_output_contains "make help" "make setup" "help命令包含setup命令"
    check_output_contains "make help" "make format" "help命令包含format命令"
    check_output_contains "make help" "活跃项目:" "help命令显示活跃项目"
    
    # 默认命令 (应该等同于help)
    check_output_contains "make" "核心命令" "默认命令显示帮助信息"
    
    # status命令
    check_output_contains "make status" "项目状态详情" "status命令显示状态信息"
    check_output_contains "make status" "活跃项目数量" "status命令显示项目数量"
    
    # info命令 
    check_output_contains "make info" "工具和依赖信息" "info命令显示工具信息"
    run_command "make info" "info命令执行成功"
    
    echo ""
    
    # 3. 智能检测机制测试
    echo -e "${YELLOW}📋 3. 智能检测机制测试${RESET}"
    
    # 调试命令
    check_output_contains "make _debug" "项目检测测试" "_debug命令显示检测信息"
    check_output_contains "make _debug" "ACTIVE_PROJECTS" "_debug显示活跃项目变量"
    check_output_contains "make _debug" "CURRENT_CONTEXT" "_debug显示当前上下文"
    
    # 检查项目自动检测
    local active_projects=$(make _debug 2>&1 | grep "ACTIVE_PROJECTS:" | cut -d"'" -f2 | xargs)
    if [[ "$active_projects" =~ "go" ]] && [[ "$active_projects" =~ "java" ]] && [[ "$active_projects" =~ "python" ]] && [[ "$active_projects" =~ "typescript" ]]; then
        log_test "智能检测识别所有项目类型" "PASS"
    else
        log_test "智能检测识别所有项目类型" "FAIL" "检测到: '$active_projects'"
    fi
    
    echo ""
    
    # 4. 格式化命令测试
    echo -e "${YELLOW}📋 4. 格式化命令测试${RESET}"
    
    run_command "make format" "智能格式化命令执行"
    check_output_contains "make format" "智能格式化:" "format显示智能格式化标题"
    check_output_contains "make format" "格式化完成:" "format显示完成消息"
    
    echo ""
    
    # 5. 代码检查命令测试
    echo -e "${YELLOW}📋 5. 代码检查命令测试${RESET}"
    
    run_command "make check" "智能代码检查命令执行"
    check_output_contains "make check" "智能质量检查:" "check显示检查标题"
    
    # lint命令 (应该等同于check)
    run_command "make lint" "lint命令执行"
    
    echo ""
    
    # 6. 构建和测试命令
    echo -e "${YELLOW}📋 6. 构建和测试命令测试${RESET}"
    
    run_command "make build" "智能构建命令执行"
    run_command "make test" "智能测试命令执行"
    run_command "make clean" "智能清理命令执行"
    
    echo ""
    
    # 7. Git相关命令测试
    echo -e "${YELLOW}📋 7. Git相关命令测试${RESET}"
    
    check_output_contains "make hooks" "Git钩子管理" "hooks命令显示管理菜单"
    check_output_contains "make hooks" "hooks-install" "hooks菜单包含安装选项"
    
    echo ""
    
    # 8. 高级命令测试
    echo -e "${YELLOW}📋 8. 高级命令测试${RESET}"
    
    run_command "make ci" "CI流程命令执行"
    run_command "make fix" "自动修复命令执行"
    
    echo ""
    
    # 9. 向后兼容性测试
    echo -e "${YELLOW}📋 9. 向后兼容性测试${RESET}"
    
    run_command "make enable-legacy" "启用旧命令集"
    
    # 测试一些旧命令是否可用
    run_command "make fmt-go" "旧的Go格式化命令可用"
    run_command "make check-tools-go" "旧的Go工具检查命令可用"
    run_command "make project-status" "旧的项目状态命令可用"
    
    echo ""
    
    # 10. 错误处理测试
    echo -e "${YELLOW}📋 10. 错误处理和边界情况测试${RESET}"
    
    # 测试不存在的命令
    run_command "make nonexistent-command" "不存在命令处理" false
    
    # 测试工具检查
    run_command "make check-tools-go" "Go工具检查"
    run_command "make check-tools-java" "Java工具检查"
    run_command "make check-tools-python" "Python工具检查"
    run_command "make check-tools-typescript" "TypeScript工具检查"
    
    echo ""
    
    # 11. 性能和警告测试
    echo -e "${YELLOW}📋 11. 性能和警告测试${RESET}"
    
    # 检查是否有警告
    local output=$(make help 2>&1)
    if echo "$output" | grep -q "warning"; then
        log_test "无Makefile警告" "FAIL" "发现Makefile警告"
    else
        log_test "无Makefile警告" "PASS"
    fi
    
    # 检查是否有错误
    if echo "$output" | grep -q "error"; then
        log_test "无Makefile错误" "FAIL" "发现Makefile错误"
    else
        log_test "无Makefile错误" "PASS"
    fi
    
    echo ""
    
    # 12. 命令数量验证
    echo -e "${YELLOW}📋 12. 命令数量和结构验证${RESET}"
    
    # 检查核心命令数量 (应该是15个左右)
    local help_output=$(make help 2>&1)
    local core_commands=$(echo "$help_output" | grep -c "make [a-z]")
    
    if [ "$core_commands" -ge 10 ] && [ "$core_commands" -le 20 ]; then
        log_test "核心命令数量合理" "PASS"
    else
        log_test "核心命令数量合理" "FAIL" "发现 $core_commands 个命令"
    fi
    
    # 检查是否包含智能检测信息
    if echo "$help_output" | grep -q "智能检测:"; then
        log_test "显示智能检测信息" "PASS"
    else
        log_test "显示智能检测信息" "FAIL"
    fi
    
    echo ""
}

# 生成测试报告
generate_report() {
    echo -e "${BLUE}==============================================================================${RESET}"
    echo -e "${BLUE}📊 测试报告${RESET}"
    echo -e "${BLUE}==============================================================================${RESET}"
    echo ""
    
    echo -e "${YELLOW}总体统计:${RESET}"
    echo "  总测试数量: $TOTAL_TESTS"
    echo -e "  通过测试: ${GREEN}$PASSED_TESTS${RESET}"
    echo -e "  失败测试: ${RED}$FAILED_TESTS${RESET}"
    
    local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo "  成功率: $success_rate%"
    echo ""
    
    if [ $FAILED_TESTS -gt 0 ]; then
        echo -e "${RED}失败的测试:${RESET}"
        for result in "${TEST_RESULTS[@]}"; do
            if [[ $result == FAIL* ]]; then
                echo "  - ${result#FAIL: }"
            fi
        done
        echo ""
    fi
    
    echo -e "${YELLOW}测试环境信息:${RESET}"
    echo "  工作目录: $(pwd)"
    echo "  Make版本: $(make --version | head -1)"
    echo "  测试时间: $(date)"
    echo ""
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}🎉 所有测试通过！Makefile优化成功！${RESET}"
        return 0
    else
        echo -e "${RED}❌ 发现 $FAILED_TESTS 个问题，需要修复${RESET}"
        return 1
    fi
}

# 检查是否在正确的目录
check_environment() {
    if [ ! -f "Makefile" ]; then
        echo -e "${RED}错误: 请在包含Makefile的目录中运行此测试${RESET}"
        exit 1
    fi
}

# 脚本入口
echo "开始Makefile全面测试..."
check_environment
main
echo ""
generate_report
exit $?