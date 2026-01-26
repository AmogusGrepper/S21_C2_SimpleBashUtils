#!/usr/bin/env bash

# Comprehensive test script for s21_grep
# Tests all flags: -e, -i, -v, -c, -l, -n, -h, -s, -f, -o

set +e  # Don't exit on error, we want to run all tests

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0
TOTAL=0

# Paths
GREP_BIN="./s21_grep"
DATA_DIR="data-samples"

# Function to run a test
run_test() {
    local test_name="$1"
    local flags="$2"
    local pattern="$3"
    local files="$4"
    local description="$5"
    
    TOTAL=$((TOTAL + 1))
    
    echo -n "Test $TOTAL: $test_name ... "
    
    # Run s21_grep
    local s21_output=$(eval "$GREP_BIN $flags \"$pattern\" $files" 2>&1)
    local s21_exit=$?
    
    # Run standard grep
    local grep_output=$(eval "grep $flags \"$pattern\" $files" 2>&1)
    local grep_exit=$?
    
    # Compare outputs
    if [ "$s21_output" = "$grep_output" ] && [ "$s21_exit" = "$grep_exit" ]; then
        echo -e "${GREEN}PASSED${NC}"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        echo "  Description: $description"
        echo "  Command: $GREP_BIN $flags \"$pattern\" $files"
        echo "  s21_grep output:"
        echo "$s21_output" | sed 's/^/    /'
        echo "  grep output:"
        echo "$grep_output" | sed 's/^/    /'
        echo "  s21_exit: $s21_exit, grep_exit: $grep_exit"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Build s21_grep first
echo "Building s21_grep..."
make s21_grep > /dev/null 2>&1

if [ ! -f "$GREP_BIN" ]; then
    echo -e "${RED}Error: $GREP_BIN not found${NC}"
    exit 1
fi

echo ""
echo "=========================================="
echo "  Comprehensive s21_grep Test Suite"
echo "=========================================="
echo ""

# Create a pattern file for -f flag tests
PATTERN_FILE="test_patterns.txt"
echo -e "error\nwarning" > "$PATTERN_FILE"

# ============================================
# Basic Flags Tests
# ============================================

echo "=== Basic Flags ==="

# -e flag (basic pattern)
run_test "Basic -e flag" "-e" "test" "$DATA_DIR/simple.txt" "Basic pattern matching"

# -e flag with multiple patterns (special handling)
TOTAL=$((TOTAL + 1))
echo -n "Test $TOTAL: -e with multiple patterns ... "
s21_output=$(eval "$GREP_BIN -e test -e grep $DATA_DIR/simple.txt" 2>&1)
s21_exit=$?
grep_output=$(eval "grep -e test -e grep $DATA_DIR/simple.txt" 2>&1)
grep_exit=$?
if [ "$s21_output" = "$grep_output" ] && [ "$s21_exit" = "$grep_exit" ]; then
    echo -e "${GREEN}PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}FAILED${NC}"
    echo "  s21_grep output:"
    echo "$s21_output" | sed 's/^/    /'
    echo "  grep output:"
    echo "$grep_output" | sed 's/^/    /'
    FAILED=$((FAILED + 1))
fi

# -i flag (case insensitive)
run_test "-i flag" "-i" "hello" "$DATA_DIR/case_test.txt" "Case insensitive matching"

# -v flag (invert match)
run_test "-v flag" "-v" "apple" "$DATA_DIR/case_test.txt" "Invert match"

# -c flag (count)
run_test "-c flag" "-c" "apple" "$DATA_DIR/case_test.txt" "Count matching lines"

# -l flag (files with matches)
run_test "-l flag" "-l" "error" "$DATA_DIR/patterns.txt $DATA_DIR/multi_files_1.txt" "List files with matches"

# -n flag (line numbers)
run_test "-n flag" "-n" "test" "$DATA_DIR/simple.txt" "Show line numbers"

# ============================================
# Part 3 Flags Tests
# ============================================

echo ""
echo "=== Part 3 Flags ==="

# -h flag (no filename)
run_test "-h flag" "-h" "error" "$DATA_DIR/patterns.txt $DATA_DIR/multi_files_1.txt" "Suppress filenames"

# -h flag with -n
run_test "-h with -n" "-hn" "error" "$DATA_DIR/patterns.txt $DATA_DIR/multi_files_1.txt" "Suppress filenames with line numbers"

# -h flag with -c
run_test "-h with -c" "-hc" "error" "$DATA_DIR/patterns.txt $DATA_DIR/multi_files_1.txt" "Suppress filenames with count"

# -s flag (suppress errors) - special handling, compare stdout only
TOTAL=$((TOTAL + 1))
echo -n "Test $TOTAL: -s flag ... "
s21_output=$(eval "$GREP_BIN -s \"pattern\" nonexistent_file.txt" 2>&1 | grep -v "open_file:" | tr -d '\n' || true)
s21_exit=$?
grep_output=$(eval "grep -s \"pattern\" nonexistent_file.txt" 2>&1 | tr -d '\n')
grep_exit=$?
if [ "$s21_output" = "$grep_output" ] && [ "$s21_exit" = "$grep_exit" ]; then
    echo -e "${GREEN}PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}FAILED${NC}"
    echo "  s21_grep output: '$s21_output'"
    echo "  grep output: '$grep_output'"
    echo "  s21_exit: $s21_exit, grep_exit: $grep_exit"
    FAILED=$((FAILED + 1))
fi

# -f flag (read patterns from file) - special handling
TOTAL=$((TOTAL + 1))
echo -n "Test $TOTAL: -f flag ... "
s21_output=$(eval "$GREP_BIN -f $PATTERN_FILE $DATA_DIR/multi_files_1.txt" 2>&1)
s21_exit=$?
grep_output=$(eval "grep -f $PATTERN_FILE $DATA_DIR/multi_files_1.txt" 2>&1)
grep_exit=$?
if [ "$s21_output" = "$grep_output" ] && [ "$s21_exit" = "$grep_exit" ]; then
    echo -e "${GREEN}PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}FAILED${NC}"
    echo "  s21_grep output:"
    echo "$s21_output" | sed 's/^/    /'
    echo "  grep output:"
    echo "$grep_output" | sed 's/^/    /'
    FAILED=$((FAILED + 1))
fi

# -f flag with -i - special handling
TOTAL=$((TOTAL + 1))
echo -n "Test $TOTAL: -f with -i ... "
s21_output=$(eval "$GREP_BIN -i -f $PATTERN_FILE $DATA_DIR/multi_files_1.txt" 2>&1)
s21_exit=$?
grep_output=$(eval "grep -i -f $PATTERN_FILE $DATA_DIR/multi_files_1.txt" 2>&1)
grep_exit=$?
if [ "$s21_output" = "$grep_output" ] && [ "$s21_exit" = "$grep_exit" ]; then
    echo -e "${GREEN}PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}FAILED${NC}"
    echo "  s21_grep output:"
    echo "$s21_output" | sed 's/^/    /'
    echo "  grep output:"
    echo "$grep_output" | sed 's/^/    /'
    FAILED=$((FAILED + 1))
fi

# -o flag (only matching parts)
run_test "-o flag" "-o" "error" "$DATA_DIR/multi_files_1.txt" "Print only matching parts"

# -o flag with -n
run_test "-o with -n" "-on" "error" "$DATA_DIR/multi_files_1.txt" "Only matches with line numbers"

# -o flag with -h
run_test "-o with -h" "-oh" "error" "$DATA_DIR/patterns.txt $DATA_DIR/multi_files_1.txt" "Only matches without filenames"

# -o flag with multiple matches per line
run_test "-o multiple matches" "-o" "a" "$DATA_DIR/simple.txt" "Multiple matches per line"

# ============================================
# Flag Combinations
# ============================================

echo ""
echo "=== Flag Combinations ==="

# -iv (invert + case insensitive)
run_test "-iv combination" "-iv" "APPLE" "$DATA_DIR/case_test.txt" "Invert match case insensitive"

# -in (case insensitive + line numbers)
run_test "-in combination" "-in" "apple" "$DATA_DIR/case_test.txt" "Case insensitive with line numbers"

# -cv (count + invert)
run_test "-cv combination" "-cv" "apple" "$DATA_DIR/case_test.txt" "Count inverted matches"

# -lv (list files + invert)
run_test "-lv combination" "-lv" "apple" "$DATA_DIR/case_test.txt $DATA_DIR/simple.txt" "List files with inverted matches"

# -hn (no filename + line numbers)
run_test "-hn combination" "-hn" "test" "$DATA_DIR/simple.txt $DATA_DIR/patterns.txt" "No filename with line numbers"

# -hc (no filename + count)
run_test "-hc combination" "-hc" "error" "$DATA_DIR/patterns.txt $DATA_DIR/multi_files_1.txt" "No filename with count"

# -ic (case insensitive + count)
run_test "-ic combination" "-ic" "apple" "$DATA_DIR/case_test.txt" "Case insensitive count"

# -il (case insensitive + list files)
run_test "-il combination" "-il" "apple" "$DATA_DIR/case_test.txt $DATA_DIR/simple.txt" "Case insensitive list files"

# -nc (line numbers + count)
run_test "-nc combination" "-nc" "test" "$DATA_DIR/simple.txt" "Line numbers with count (should ignore -n)"

# -f with -v - special handling
TOTAL=$((TOTAL + 1))
echo -n "Test $TOTAL: -f with -v ... "
s21_output=$(eval "$GREP_BIN -v -f $PATTERN_FILE $DATA_DIR/multi_files_1.txt" 2>&1)
s21_exit=$?
grep_output=$(eval "grep -v -f $PATTERN_FILE $DATA_DIR/multi_files_1.txt" 2>&1)
grep_exit=$?
if [ "$s21_output" = "$grep_output" ] && [ "$s21_exit" = "$grep_exit" ]; then
    echo -e "${GREEN}PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}FAILED${NC}"
    echo "  s21_grep output:"
    echo "$s21_output" | sed 's/^/    /'
    echo "  grep output:"
    echo "$grep_output" | sed 's/^/    /'
    FAILED=$((FAILED + 1))
fi

# -f with -c - special handling
TOTAL=$((TOTAL + 1))
echo -n "Test $TOTAL: -f with -c ... "
s21_output=$(eval "$GREP_BIN -c -f $PATTERN_FILE $DATA_DIR/multi_files_1.txt" 2>&1)
s21_exit=$?
grep_output=$(eval "grep -c -f $PATTERN_FILE $DATA_DIR/multi_files_1.txt" 2>&1)
grep_exit=$?
if [ "$s21_output" = "$grep_output" ] && [ "$s21_exit" = "$grep_exit" ]; then
    echo -e "${GREEN}PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}FAILED${NC}"
    echo "  s21_grep output:"
    echo "$s21_output" | sed 's/^/    /'
    echo "  grep output:"
    echo "$grep_output" | sed 's/^/    /'
    FAILED=$((FAILED + 1))
fi

# -f with -l - special handling
TOTAL=$((TOTAL + 1))
echo -n "Test $TOTAL: -f with -l ... "
s21_output=$(eval "$GREP_BIN -l -f $PATTERN_FILE $DATA_DIR/patterns.txt $DATA_DIR/multi_files_1.txt" 2>&1)
s21_exit=$?
grep_output=$(eval "grep -l -f $PATTERN_FILE $DATA_DIR/patterns.txt $DATA_DIR/multi_files_1.txt" 2>&1)
grep_exit=$?
if [ "$s21_output" = "$grep_output" ] && [ "$s21_exit" = "$grep_exit" ]; then
    echo -e "${GREEN}PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}FAILED${NC}"
    echo "  s21_grep output:"
    echo "$s21_output" | sed 's/^/    /'
    echo "  grep output:"
    echo "$grep_output" | sed 's/^/    /'
    FAILED=$((FAILED + 1))
fi

# -o with -i
run_test "-o with -i" "-oi" "APPLE" "$DATA_DIR/case_test.txt" "Only matches case insensitive"

# -o with -c (should ignore -o)
run_test "-o with -c" "-oc" "error" "$DATA_DIR/multi_files_1.txt" "Only matches with count (should ignore -o)"

# -o with -l (should ignore -o)
run_test "-o with -l" "-ol" "error" "$DATA_DIR/patterns.txt $DATA_DIR/multi_files_1.txt" "Only matches with list (should ignore -o)"

# ============================================
# Edge Cases
# ============================================

echo ""
echo "=== Edge Cases ==="

# Empty file
run_test "Empty file" "" "pattern" "$DATA_DIR/only_empty.txt" "Search in empty file"

# File with only empty lines
run_test "Only empty lines" "" "pattern" "$DATA_DIR/empty_lines.txt" "Search in file with only empty lines"

# Pattern not found
run_test "Pattern not found" "" "nonexistentpattern123" "$DATA_DIR/simple.txt" "Pattern that doesn't exist"

# Multiple files, pattern in some
run_test "Multiple files partial match" "" "error" "$DATA_DIR/simple.txt $DATA_DIR/patterns.txt" "Pattern in some files"

# Regex patterns
run_test "Regex pattern" "" "a.*c" "$DATA_DIR/regex_test.txt" "Basic regex pattern"

# -e with regex (note: we use REG_EXTENDED like grep -E, not basic regex)
TOTAL=$((TOTAL + 1))
echo -n "Test $TOTAL: -e with regex (extended) ... "
s21_output=$(eval "$GREP_BIN -e \"ab+c\" $DATA_DIR/regex_test.txt" 2>&1)
s21_exit=$?
grep_output=$(eval "grep -E -e \"ab+c\" $DATA_DIR/regex_test.txt" 2>&1)
grep_exit=$?
if [ "$s21_output" = "$grep_output" ] && [ "$s21_exit" = "$grep_exit" ]; then
    echo -e "${GREEN}PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}FAILED${NC}"
    echo "  Note: s21_grep uses extended regex (like grep -E)"
    echo "  s21_grep output:"
    echo "$s21_output" | sed 's/^/    /'
    echo "  grep -E output:"
    echo "$grep_output" | sed 's/^/    /'
    FAILED=$((FAILED + 1))
fi

# -o with regex (multiple matches)
run_test "-o with regex" "-o" "a" "$DATA_DIR/simple.txt" "Regex with only matches"

# -f with empty pattern file (should handle gracefully) - special handling
echo "" > empty_patterns.txt
TOTAL=$((TOTAL + 1))
echo -n "Test $TOTAL: -f empty pattern file ... "
s21_output=$(eval "$GREP_BIN -f empty_patterns.txt $DATA_DIR/simple.txt" 2>&1)
s21_exit=$?
grep_output=$(eval "grep -f empty_patterns.txt $DATA_DIR/simple.txt" 2>&1)
grep_exit=$?
if [ "$s21_output" = "$grep_output" ] && [ "$s21_exit" = "$grep_exit" ]; then
    echo -e "${GREEN}PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}FAILED${NC}"
    echo "  s21_grep output:"
    echo "$s21_output" | sed 's/^/    /'
    echo "  grep output:"
    echo "$grep_output" | sed 's/^/    /'
    FAILED=$((FAILED + 1))
fi

# -s with multiple nonexistent files - special handling
TOTAL=$((TOTAL + 1))
echo -n "Test $TOTAL: -s multiple nonexistent ... "
s21_output=$(eval "$GREP_BIN -s \"pattern\" nonexistent1.txt nonexistent2.txt" 2>&1 | grep -v "open_file:" | tr -d '\n' || true)
s21_exit=$?
grep_output=$(eval "grep -s \"pattern\" nonexistent1.txt nonexistent2.txt" 2>&1 | tr -d '\n')
grep_exit=$?
if [ "$s21_output" = "$grep_output" ] && [ "$s21_exit" = "$grep_exit" ]; then
    echo -e "${GREEN}PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}FAILED${NC}"
    echo "  s21_grep output: '$s21_output'"
    echo "  grep output: '$grep_output'"
    echo "  s21_exit: $s21_exit, grep_exit: $grep_exit"
    FAILED=$((FAILED + 1))
fi

# -h with single file (should work same as without -h)
run_test "-h single file" "-h" "test" "$DATA_DIR/simple.txt" "Suppress filename with single file"

# -o with -v (should ignore -o, standard grep behavior)
run_test "-o with -v" "-ov" "apple" "$DATA_DIR/case_test.txt" "Only matches with invert (should ignore -o)"

# ============================================
# Complex Scenarios
# ============================================

echo ""
echo "=== Complex Scenarios ==="

# Multiple -e patterns (special handling)
TOTAL=$((TOTAL + 1))
echo -n "Test $TOTAL: Multiple -e patterns ... "
s21_output=$(eval "$GREP_BIN -e test -e grep -e Simple $DATA_DIR/simple.txt" 2>&1)
s21_exit=$?
grep_output=$(eval "grep -e test -e grep -e Simple $DATA_DIR/simple.txt" 2>&1)
grep_exit=$?
if [ "$s21_output" = "$grep_output" ] && [ "$s21_exit" = "$grep_exit" ]; then
    echo -e "${GREEN}PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}FAILED${NC}"
    echo "  s21_grep output:"
    echo "$s21_output" | sed 's/^/    /'
    echo "  grep output:"
    echo "$grep_output" | sed 's/^/    /'
    FAILED=$((FAILED + 1))
fi

# -f with multiple patterns in file - special handling
echo -e "test\ngrep\nSimple" > multi_patterns.txt
TOTAL=$((TOTAL + 1))
echo -n "Test $TOTAL: -f multiple patterns ... "
s21_output=$(eval "$GREP_BIN -f multi_patterns.txt $DATA_DIR/simple.txt" 2>&1)
s21_exit=$?
grep_output=$(eval "grep -f multi_patterns.txt $DATA_DIR/simple.txt" 2>&1)
grep_exit=$?
if [ "$s21_output" = "$grep_output" ] && [ "$s21_exit" = "$grep_exit" ]; then
    echo -e "${GREEN}PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}FAILED${NC}"
    echo "  s21_grep output:"
    echo "$s21_output" | sed 's/^/    /'
    echo "  grep output:"
    echo "$grep_output" | sed 's/^/    /'
    FAILED=$((FAILED + 1))
fi

# -f with -i and -n - special handling
TOTAL=$((TOTAL + 1))
echo -n "Test $TOTAL: -f with -i and -n ... "
s21_output=$(eval "$GREP_BIN -i -n -f multi_patterns.txt $DATA_DIR/simple.txt" 2>&1)
s21_exit=$?
grep_output=$(eval "grep -i -n -f multi_patterns.txt $DATA_DIR/simple.txt" 2>&1)
grep_exit=$?
if [ "$s21_output" = "$grep_output" ] && [ "$s21_exit" = "$grep_exit" ]; then
    echo -e "${GREEN}PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}FAILED${NC}"
    echo "  s21_grep output:"
    echo "$s21_output" | sed 's/^/    /'
    echo "  grep output:"
    echo "$grep_output" | sed 's/^/    /'
    FAILED=$((FAILED + 1))
fi

# -o with -h and -n
run_test "-o with -h and -n" "-ohn" "error" "$DATA_DIR/patterns.txt $DATA_DIR/multi_files_1.txt" "Only matches no filename with line numbers"

# All flags together (valid combination)
run_test "Complex flag combination" "-ihn" "test" "$DATA_DIR/simple.txt $DATA_DIR/patterns.txt" "Case insensitive, no filename, line numbers"

# ============================================
# Summary
# ============================================

echo ""
echo "=========================================="
echo "  Test Summary"
echo "=========================================="
echo "Total tests: $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

# Cleanup
rm -f "$PATTERN_FILE" empty_patterns.txt multi_patterns.txt 2>/dev/null || true

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Please review the output above.${NC}"
    exit 1
fi
