#!/usr/bin/env bash

# ==============================================================================
# COMPREHENSIVE TEST SUITE FOR s21_grep
# ==============================================================================
# Tests all flags: -e, -i, -v, -c, -l, -n, -h, -s, -f, -o
# Tests all pair combinations and complex scenarios
# Based on comparison with GNU grep behavior
# ==============================================================================

set +e  # Don't exit on error, we want to run all tests

# ==============================================================================
# Configuration
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PASSED=0
FAILED=0
TOTAL=0
FAILED_TESTS=()

GREP_BIN="./s21_grep"
DATA_DIR="data-samples"
TEMP_DIR="/tmp/s21_grep_test_$$"

# ==============================================================================
# Test Data Files
# ==============================================================================

TEST_FILE1="${DATA_DIR}/simple.txt"
TEST_FILE2="${DATA_DIR}/case_test.txt"
TEST_FILE3="${DATA_DIR}/patterns.txt"
TEST_FILE4="${DATA_DIR}/multi_files_1.txt"
TEST_FILE5="${DATA_DIR}/multi_files_2.txt"
TEST_FILE6="${DATA_DIR}/regex_test.txt"
TEST_FILE7="${DATA_DIR}/empty_lines.txt"
TEST_FILE8="${DATA_DIR}/numbers.txt"
TEST_FILE9="${DATA_DIR}/only_empty.txt"
TEST_FILE10="${DATA_DIR}/mixed_chars.txt"

# ==============================================================================
# Setup and Cleanup Functions
# ==============================================================================

setup() {
    mkdir -p "$TEMP_DIR"
    
    # Create pattern files for -f flag tests
    echo -e "error\nwarning" > "${TEMP_DIR}/patterns1.txt"
    echo -e "test\ngrep" > "${TEMP_DIR}/patterns2.txt"
    echo -e "Apple\napple" > "${TEMP_DIR}/patterns_case.txt"
    echo "" > "${TEMP_DIR}/empty_pattern.txt"
    echo -e "a.*c\n^L" > "${TEMP_DIR}/regex_patterns.txt"
    echo -e "two\nfour" > "${TEMP_DIR}/numbers_pat.txt"
    echo "nonexistent_pattern_xyz123" > "${TEMP_DIR}/nomatch_pattern.txt"
    echo -e "error\n\nwarning" > "${TEMP_DIR}/patterns_with_empty.txt"
    echo -e "abc\nabbc\nabbbc" > "${TEMP_DIR}/exact_patterns.txt"
    
    # Create additional test files
    echo -e "ERROR: critical\nerror: minor\nWarning: check\nINFO: ok" > "${TEMP_DIR}/logs.txt"
    echo -e "first\nsecond\nthird" > "${TEMP_DIR}/three_lines.txt"
    echo -e "aaa\nbbb\nccc\naaa\nbbb" > "${TEMP_DIR}/duplicates.txt"
    echo -e "line with spaces\n   leading spaces\ntrailing spaces   \n   both   " > "${TEMP_DIR}/spaces.txt"
    echo -e "^special\$chars\n[regex]chars\n*star*" > "${TEMP_DIR}/special_chars.txt"
    echo -e "ab\nabc\nabcd\nabcde" > "${TEMP_DIR}/incremental.txt"
    echo -e "one two three\nfour five six\nseven eight nine" > "${TEMP_DIR}/words.txt"
    echo -e "123\n456\n789" > "${TEMP_DIR}/digits.txt"
    echo -e "test1\ntest2\ntest3\nother1\nother2" > "${TEMP_DIR}/numbered.txt"
    printf "no newline at end" > "${TEMP_DIR}/no_newline.txt"
    echo -e "UPPER\nlower\nMixed" > "${TEMP_DIR}/case_mix.txt"
    echo -e "a\naa\naaa\naaaa" > "${TEMP_DIR}/repeated_a.txt"
    echo -e "match1 match2 match3\nsingle\nno_match_here" > "${TEMP_DIR}/multi_match.txt"
    echo -e "" > "${TEMP_DIR}/single_empty.txt"
    echo -e "only_one_line" > "${TEMP_DIR}/single_line.txt"
    echo -e "the quick brown fox\njumps over the lazy dog\nthe end" > "${TEMP_DIR}/fox.txt"
}

cleanup() {
    rm -rf "$TEMP_DIR"
}

# ==============================================================================
# Core Test Function
# ==============================================================================

run_test() {
    local test_name="$1"
    local s21_cmd="$2"
    local grep_cmd="$3"
    local description="$4"
    
    TOTAL=$((TOTAL + 1))
    
    # Run s21_grep
    local s21_output
    local s21_exit
    s21_output=$(eval "$s21_cmd" 2>&1)
    s21_exit=$?
    
    # Run standard grep
    local grep_output
    local grep_exit
    grep_output=$(eval "$grep_cmd" 2>&1)
    grep_exit=$?
    
    # Compare outputs
    if [ "$s21_output" = "$grep_output" ] && [ "$s21_exit" = "$grep_exit" ]; then
        echo -e "${GREEN}[PASS]${NC} Test $TOTAL: $test_name"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}[FAIL]${NC} Test $TOTAL: $test_name"
        echo -e "  ${CYAN}Description:${NC} $description"
        echo -e "  ${CYAN}s21_cmd:${NC} $s21_cmd"
        echo -e "  ${CYAN}grep_cmd:${NC} $grep_cmd"
        echo -e "  ${CYAN}s21_grep output (exit=$s21_exit):${NC}"
        echo "$s21_output" | head -10 | sed 's/^/    /'
        [ $(echo "$s21_output" | wc -l) -gt 10 ] && echo "    ... (truncated)"
        echo -e "  ${CYAN}grep output (exit=$grep_exit):${NC}"
        echo "$grep_output" | head -10 | sed 's/^/    /'
        [ $(echo "$grep_output" | wc -l) -gt 10 ] && echo "    ... (truncated)"
        FAILED=$((FAILED + 1))
        FAILED_TESTS+=("$test_name")
        return 1
    fi
}

# Simplified test function for standard cases
run_simple_test() {
    local test_name="$1"
    local flags="$2"
    local pattern="$3"
    local files="$4"
    local description="$5"
    
    run_test "$test_name" \
        "$GREP_BIN $flags \"$pattern\" $files" \
        "grep $flags \"$pattern\" $files" \
        "$description"
}

# ==============================================================================
# Build s21_grep
# ==============================================================================

echo -e "${BLUE}Building s21_grep...${NC}"
make s21_grep > /dev/null 2>&1

if [ ! -f "$GREP_BIN" ]; then
    echo -e "${RED}Error: $GREP_BIN not found after build${NC}"
    exit 1
fi

echo -e "${GREEN}Build successful${NC}"
echo ""

# ==============================================================================
# Setup test environment
# ==============================================================================

setup
trap cleanup EXIT

echo "=========================================================================="
echo -e "${BLUE}           COMPREHENSIVE s21_grep TEST SUITE${NC}"
echo "=========================================================================="
echo ""

# ##############################################################################
# SECTION 1: BASIC PATTERN MATCHING (NO FLAGS)
# ##############################################################################

echo -e "${YELLOW}=== SECTION 1: Basic Pattern Matching (No Flags) ===${NC}"

run_simple_test "Basic match - single file" "" "test" "$TEST_FILE1" \
    "Basic pattern matching in single file"

run_simple_test "Basic match - pattern at start" "" "Hello" "$TEST_FILE1" \
    "Pattern at line start"

run_simple_test "Basic match - pattern at end" "" "END" "$TEST_FILE1" \
    "Pattern at line end"

run_simple_test "Basic match - partial word" "" "grep" "$TEST_FILE1" \
    "Partial word match"

run_simple_test "Basic match - multiple files" "" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Pattern in multiple files"

run_simple_test "Basic match - no match found" "" "nonexistent_pattern_xyz" "$TEST_FILE1" \
    "Pattern not found in file"

run_simple_test "Basic match - case sensitive" "" "apple" "$TEST_FILE2" \
    "Case-sensitive match (lowercase)"

run_simple_test "Basic match - case sensitive UPPER" "" "APPLE" "$TEST_FILE2" \
    "Case-sensitive match (uppercase)"

run_simple_test "Basic match - empty file" "" "pattern" "$TEST_FILE9" \
    "Search in empty file"

run_simple_test "Basic match - file with empty lines" "" "Line" "$TEST_FILE7" \
    "Pattern in file with empty lines"

run_simple_test "Basic match - three files" "" "error" "$TEST_FILE3 $TEST_FILE4 $TEST_FILE5" \
    "Pattern in three files"

run_simple_test "Basic match - four files" "" "error" "$TEST_FILE1 $TEST_FILE3 $TEST_FILE4 $TEST_FILE5" \
    "Pattern in four files (some without match)"

echo ""

# ##############################################################################
# SECTION 2: FLAG -e (PATTERN)
# ##############################################################################

echo -e "${YELLOW}=== SECTION 2: Flag -e (Pattern) ===${NC}"

run_simple_test "-e basic" "-e" "test" "$TEST_FILE1" \
    "Basic -e flag with pattern"

run_test "-e multiple patterns (2)" \
    "$GREP_BIN -e test -e grep $TEST_FILE1" \
    "grep -e test -e grep $TEST_FILE1" \
    "Two patterns with -e"

run_test "-e multiple patterns (3)" \
    "$GREP_BIN -e test -e grep -e Simple $TEST_FILE1" \
    "grep -e test -e grep -e Simple $TEST_FILE1" \
    "Three patterns with -e"

run_test "-e multiple patterns - no match for one" \
    "$GREP_BIN -e test -e nonexistent $TEST_FILE1" \
    "grep -e test -e nonexistent $TEST_FILE1" \
    "Multiple -e patterns, one doesn't match"

run_test "-e multiple patterns - all match" \
    "$GREP_BIN -e error -e warning $TEST_FILE3" \
    "grep -e error -e warning $TEST_FILE3" \
    "All -e patterns match"

run_test "-e multiple patterns - none match" \
    "$GREP_BIN -e xyz -e abc $TEST_FILE1" \
    "grep -e xyz -e abc $TEST_FILE1" \
    "No -e patterns match"

run_test "-e with multiple files" \
    "$GREP_BIN -e error -e warning $TEST_FILE4 $TEST_FILE5" \
    "grep -e error -e warning $TEST_FILE4 $TEST_FILE5" \
    "Multiple -e patterns with multiple files"

run_test "-e overlapping patterns" \
    "$GREP_BIN -e a -e ab -e abc $TEST_FILE6" \
    "grep -e a -e ab -e abc $TEST_FILE6" \
    "Overlapping patterns with -e"

echo ""

# ##############################################################################
# SECTION 3: FLAG -i (CASE INSENSITIVE)
# ##############################################################################

echo -e "${YELLOW}=== SECTION 3: Flag -i (Case Insensitive) ===${NC}"

run_simple_test "-i lowercase pattern" "-i" "apple" "$TEST_FILE2" \
    "Case insensitive - lowercase pattern"

run_simple_test "-i uppercase pattern" "-i" "APPLE" "$TEST_FILE2" \
    "Case insensitive - uppercase pattern"

run_simple_test "-i mixed case pattern" "-i" "ApPlE" "$TEST_FILE2" \
    "Case insensitive - mixed case pattern"

run_simple_test "-i multiple files" "-i" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Case insensitive - multiple files"

run_simple_test "-i no match" "-i" "nonexistent" "$TEST_FILE2" \
    "Case insensitive - no match"

run_simple_test "-i with numbers" "-i" "line" "$TEST_FILE7" \
    "Case insensitive - pattern in file with empty lines"

run_simple_test "-i on case-sensitive pattern" "-i" "hello" "$TEST_FILE1" \
    "Case insensitive - Hello vs hello"

echo ""

# ##############################################################################
# SECTION 4: FLAG -v (INVERT MATCH)
# ##############################################################################

echo -e "${YELLOW}=== SECTION 4: Flag -v (Invert Match) ===${NC}"

run_simple_test "-v basic" "-v" "apple" "$TEST_FILE2" \
    "Invert match - exclude lines with pattern"

run_simple_test "-v all lines match" "-v" "a" "${TEMP_DIR}/repeated_a.txt" \
    "Invert match - all lines contain pattern"

run_simple_test "-v no lines match" "-v" "nonexistent" "$TEST_FILE1" \
    "Invert match - no lines contain pattern (all output)"

run_simple_test "-v multiple files" "-v" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Invert match - multiple files"

run_simple_test "-v empty file" "-v" "pattern" "$TEST_FILE9" \
    "Invert match - empty file"

run_simple_test "-v file with empty lines" "-v" "Line" "$TEST_FILE7" \
    "Invert match - file with empty lines"

run_simple_test "-v partial match" "-v" "test" "$TEST_FILE1" \
    "Invert match - single file partial match"

echo ""

# ##############################################################################
# SECTION 5: FLAG -c (COUNT)
# ##############################################################################

echo -e "${YELLOW}=== SECTION 5: Flag -c (Count) ===${NC}"

run_simple_test "-c single file" "-c" "test" "$TEST_FILE1" \
    "Count matches - single file"

run_simple_test "-c no matches" "-c" "nonexistent" "$TEST_FILE1" \
    "Count matches - no matches"

run_simple_test "-c all lines match" "-c" "a" "${TEMP_DIR}/repeated_a.txt" \
    "Count matches - all lines"

run_simple_test "-c multiple files" "-c" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Count matches - multiple files"

run_simple_test "-c empty file" "-c" "pattern" "$TEST_FILE9" \
    "Count matches - empty file"

run_simple_test "-c three files" "-c" "error" "$TEST_FILE3 $TEST_FILE4 $TEST_FILE5" \
    "Count matches - three files"

run_simple_test "-c with pattern in all files" "-c" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Count matches - pattern in all files"

run_simple_test "-c with pattern in some files" "-c" "error" "$TEST_FILE1 $TEST_FILE4" \
    "Count matches - pattern in some files"

echo ""

# ##############################################################################
# SECTION 6: FLAG -l (FILES WITH MATCHES)
# ##############################################################################

echo -e "${YELLOW}=== SECTION 6: Flag -l (Files With Matches) ===${NC}"

run_simple_test "-l single file match" "-l" "test" "$TEST_FILE1" \
    "List files - single file with match"

run_simple_test "-l single file no match" "-l" "nonexistent" "$TEST_FILE1" \
    "List files - single file without match"

run_simple_test "-l multiple files all match" "-l" "error" "$TEST_FILE4 $TEST_FILE5" \
    "List files - all files match"

run_simple_test "-l multiple files some match" "-l" "error" "$TEST_FILE1 $TEST_FILE4 $TEST_FILE5" \
    "List files - some files match"

run_simple_test "-l multiple files none match" "-l" "nonexistent" "$TEST_FILE1 $TEST_FILE2" \
    "List files - no files match"

run_simple_test "-l three files" "-l" "error" "$TEST_FILE3 $TEST_FILE4 $TEST_FILE5" \
    "List files - three files"

run_simple_test "-l empty file" "-l" "pattern" "$TEST_FILE9" \
    "List files - empty file"

echo ""

# ##############################################################################
# SECTION 7: FLAG -n (LINE NUMBER)
# ##############################################################################

echo -e "${YELLOW}=== SECTION 7: Flag -n (Line Number) ===${NC}"

run_simple_test "-n single file" "-n" "test" "$TEST_FILE1" \
    "Line numbers - single file"

run_simple_test "-n multiple matches" "-n" "two" "$TEST_FILE8" \
    "Line numbers - multiple matches in file"

run_simple_test "-n multiple files" "-n" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Line numbers - multiple files"

run_simple_test "-n first line" "-n" "Hello" "$TEST_FILE1" \
    "Line numbers - match on first line"

run_simple_test "-n last line" "-n" "END" "$TEST_FILE1" \
    "Line numbers - match on last line"

run_simple_test "-n no match" "-n" "nonexistent" "$TEST_FILE1" \
    "Line numbers - no match"

run_simple_test "-n file with empty lines" "-n" "Line" "$TEST_FILE7" \
    "Line numbers - file with empty lines"

run_simple_test "-n three files" "-n" "error" "$TEST_FILE3 $TEST_FILE4 $TEST_FILE5" \
    "Line numbers - three files"

echo ""

# ##############################################################################
# SECTION 8: FLAG -h (NO FILENAME)
# ##############################################################################

echo -e "${YELLOW}=== SECTION 8: Flag -h (No Filename) ===${NC}"

run_simple_test "-h single file" "-h" "test" "$TEST_FILE1" \
    "No filename - single file (should have no effect)"

run_simple_test "-h multiple files" "-h" "error" "$TEST_FILE4 $TEST_FILE5" \
    "No filename - multiple files"

run_simple_test "-h three files" "-h" "error" "$TEST_FILE3 $TEST_FILE4 $TEST_FILE5" \
    "No filename - three files"

run_simple_test "-h no match multiple files" "-h" "nonexistent" "$TEST_FILE1 $TEST_FILE2" \
    "No filename - no matches in multiple files"

run_simple_test "-h with pattern in all" "-h" "error" "$TEST_FILE4 $TEST_FILE5" \
    "No filename - pattern in all files"

echo ""

# ##############################################################################
# SECTION 9: FLAG -s (SUPPRESS ERRORS)
# ##############################################################################

echo -e "${YELLOW}=== SECTION 9: Flag -s (Suppress Errors) ===${NC}"

run_test "-s nonexistent file" \
    "$GREP_BIN -s pattern nonexistent_file_xyz.txt" \
    "grep -s pattern nonexistent_file_xyz.txt" \
    "Suppress errors - nonexistent file"

run_test "-s multiple nonexistent files" \
    "$GREP_BIN -s pattern nonexistent1.txt nonexistent2.txt" \
    "grep -s pattern nonexistent1.txt nonexistent2.txt" \
    "Suppress errors - multiple nonexistent files"

run_test "-s mixed existing and nonexistent" \
    "$GREP_BIN -s test nonexistent.txt $TEST_FILE1" \
    "grep -s test nonexistent.txt $TEST_FILE1" \
    "Suppress errors - mixed files"

run_test "-s nonexistent then existing" \
    "$GREP_BIN -s error nonexistent.txt $TEST_FILE4" \
    "grep -s error nonexistent.txt $TEST_FILE4" \
    "Suppress errors - nonexistent first, then existing"

run_test "-s existing then nonexistent" \
    "$GREP_BIN -s error $TEST_FILE4 nonexistent.txt" \
    "grep -s error $TEST_FILE4 nonexistent.txt" \
    "Suppress errors - existing first, then nonexistent"

run_test "-s on existing file" \
    "$GREP_BIN -s test $TEST_FILE1" \
    "grep -s test $TEST_FILE1" \
    "Suppress errors - only existing file (no effect)"

echo ""

# ##############################################################################
# SECTION 10: FLAG -f (PATTERNS FROM FILE)
# ##############################################################################

echo -e "${YELLOW}=== SECTION 10: Flag -f (Patterns From File) ===${NC}"

run_test "-f basic" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns1.txt $TEST_FILE4" \
    "grep -f ${TEMP_DIR}/patterns1.txt $TEST_FILE4" \
    "Patterns from file - basic"

run_test "-f multiple patterns" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns2.txt $TEST_FILE1" \
    "grep -f ${TEMP_DIR}/patterns2.txt $TEST_FILE1" \
    "Patterns from file - multiple patterns"

run_test "-f with multiple files" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns1.txt $TEST_FILE4 $TEST_FILE5" \
    "grep -f ${TEMP_DIR}/patterns1.txt $TEST_FILE4 $TEST_FILE5" \
    "Patterns from file - multiple files"

run_test "-f empty pattern file" \
    "$GREP_BIN -f ${TEMP_DIR}/empty_pattern.txt $TEST_FILE1" \
    "grep -f ${TEMP_DIR}/empty_pattern.txt $TEST_FILE1" \
    "Patterns from file - empty pattern file"

run_test "-f with regex patterns" \
    "$GREP_BIN -f ${TEMP_DIR}/regex_patterns.txt $TEST_FILE6" \
    "grep -f ${TEMP_DIR}/regex_patterns.txt $TEST_FILE6" \
    "Patterns from file - regex patterns"

run_test "-f three pattern file" \
    "$GREP_BIN -f ${TEMP_DIR}/exact_patterns.txt $TEST_FILE6" \
    "grep -f ${TEMP_DIR}/exact_patterns.txt $TEST_FILE6" \
    "Patterns from file - exact match patterns"

run_test "-f no matches" \
    "$GREP_BIN -f ${TEMP_DIR}/nomatch_pattern.txt $TEST_FILE1" \
    "grep -f ${TEMP_DIR}/nomatch_pattern.txt $TEST_FILE1" \
    "Patterns from file - no matches"

run_test "-f patterns with empty lines" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns_with_empty.txt $TEST_FILE4" \
    "grep -f ${TEMP_DIR}/patterns_with_empty.txt $TEST_FILE4" \
    "Patterns from file - pattern file has empty lines"

echo ""

# ##############################################################################
# SECTION 11: FLAG -o (ONLY MATCHING)
# ##############################################################################

echo -e "${YELLOW}=== SECTION 11: Flag -o (Only Matching) ===${NC}"

run_simple_test "-o basic" "-o" "error" "$TEST_FILE4" \
    "Only matching - basic"

run_simple_test "-o multiple matches per line" "-o" "match" "${TEMP_DIR}/multi_match.txt" \
    "Only matching - multiple matches per line"

run_simple_test "-o single char" "-o" "a" "${TEMP_DIR}/repeated_a.txt" \
    "Only matching - single character pattern"

run_simple_test "-o no match" "-o" "nonexistent" "$TEST_FILE1" \
    "Only matching - no matches"

run_simple_test "-o multiple files" "-o" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Only matching - multiple files"

run_simple_test "-o regex pattern" "-o" "ab*c" "$TEST_FILE6" \
    "Only matching - regex pattern"

run_simple_test "-o word pattern" "-o" "test" "$TEST_FILE1" \
    "Only matching - word pattern"

run_simple_test "-o overlapping potential" "-o" "aa" "${TEMP_DIR}/repeated_a.txt" \
    "Only matching - overlapping matches"

echo ""

# ##############################################################################
# SECTION 12: TWO-FLAG COMBINATIONS
# ##############################################################################

echo -e "${YELLOW}=== SECTION 12: Two-Flag Combinations ===${NC}"

# -e with other flags
run_test "-e -i combination" \
    "$GREP_BIN -e apple -i $TEST_FILE2" \
    "grep -e apple -i $TEST_FILE2" \
    "-e with -i"

run_test "-e -v combination" \
    "$GREP_BIN -e apple -v $TEST_FILE2" \
    "grep -e apple -v $TEST_FILE2" \
    "-e with -v"

run_test "-e -c combination" \
    "$GREP_BIN -e error -c $TEST_FILE4" \
    "grep -e error -c $TEST_FILE4" \
    "-e with -c"

run_test "-e -l combination" \
    "$GREP_BIN -e error -l $TEST_FILE4 $TEST_FILE5" \
    "grep -e error -l $TEST_FILE4 $TEST_FILE5" \
    "-e with -l"

run_test "-e -n combination" \
    "$GREP_BIN -e error -n $TEST_FILE4" \
    "grep -e error -n $TEST_FILE4" \
    "-e with -n"

run_test "-e -h combination" \
    "$GREP_BIN -e error -h $TEST_FILE4 $TEST_FILE5" \
    "grep -e error -h $TEST_FILE4 $TEST_FILE5" \
    "-e with -h"

run_test "-e -o combination" \
    "$GREP_BIN -e error -o $TEST_FILE4" \
    "grep -e error -o $TEST_FILE4" \
    "-e with -o"

# -i with other flags
run_simple_test "-i -v (invert case insensitive)" "-iv" "apple" "$TEST_FILE2" \
    "-i with -v"

run_simple_test "-i -c (count case insensitive)" "-ic" "apple" "$TEST_FILE2" \
    "-i with -c"

run_simple_test "-i -l (list case insensitive)" "-il" "apple" "$TEST_FILE2 $TEST_FILE1" \
    "-i with -l"

run_simple_test "-i -n (line num case insensitive)" "-in" "apple" "$TEST_FILE2" \
    "-i with -n"

run_simple_test "-i -h (no filename case insensitive)" "-ih" "error" "$TEST_FILE4 $TEST_FILE5" \
    "-i with -h"

run_simple_test "-i -o (only match case insensitive)" "-io" "apple" "$TEST_FILE2" \
    "-i with -o"

# -v with other flags
run_simple_test "-v -c (count inverted)" "-vc" "apple" "$TEST_FILE2" \
    "-v with -c"

run_simple_test "-v -l (list inverted)" "-vl" "error" "$TEST_FILE4 $TEST_FILE5" \
    "-v with -l"

run_simple_test "-v -n (line num inverted)" "-vn" "apple" "$TEST_FILE2" \
    "-v with -n"

run_simple_test "-v -h (no filename inverted)" "-vh" "error" "$TEST_FILE4 $TEST_FILE5" \
    "-v with -h"

run_simple_test "-v -o (only match inverted)" "-vo" "apple" "$TEST_FILE2" \
    "-v with -o (should ignore -o per standard grep)"

# -c with other flags
run_simple_test "-c -l (count + list)" "-cl" "error" "$TEST_FILE4 $TEST_FILE5" \
    "-c with -l"

run_simple_test "-c -n (count + line num)" "-cn" "error" "$TEST_FILE4" \
    "-c with -n (n should be ignored)"

run_simple_test "-c -h (count + no filename)" "-ch" "error" "$TEST_FILE4 $TEST_FILE5" \
    "-c with -h"

run_simple_test "-c -o (count + only match)" "-co" "error" "$TEST_FILE4" \
    "-c with -o (o should be ignored)"

# -l with other flags
run_simple_test "-l -n (list + line num)" "-ln" "error" "$TEST_FILE4 $TEST_FILE5" \
    "-l with -n (n should be ignored)"

run_simple_test "-l -h (list + no filename)" "-lh" "error" "$TEST_FILE4 $TEST_FILE5" \
    "-l with -h"

run_simple_test "-l -o (list + only match)" "-lo" "error" "$TEST_FILE4 $TEST_FILE5" \
    "-l with -o (o should be ignored)"

# -n with other flags
run_simple_test "-n -h (line num + no filename)" "-nh" "error" "$TEST_FILE4 $TEST_FILE5" \
    "-n with -h"

run_simple_test "-n -o (line num + only match)" "-no" "error" "$TEST_FILE4" \
    "-n with -o"

# -h with other flags
run_simple_test "-h -o (no filename + only match)" "-ho" "error" "$TEST_FILE4 $TEST_FILE5" \
    "-h with -o"

# -f with other flags
run_test "-f -i combination" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns_case.txt -i $TEST_FILE2" \
    "grep -f ${TEMP_DIR}/patterns_case.txt -i $TEST_FILE2" \
    "-f with -i"

run_test "-f -v combination" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns1.txt -v $TEST_FILE4" \
    "grep -f ${TEMP_DIR}/patterns1.txt -v $TEST_FILE4" \
    "-f with -v"

run_test "-f -c combination" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns1.txt -c $TEST_FILE4" \
    "grep -f ${TEMP_DIR}/patterns1.txt -c $TEST_FILE4" \
    "-f with -c"

run_test "-f -l combination" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns1.txt -l $TEST_FILE4 $TEST_FILE5" \
    "grep -f ${TEMP_DIR}/patterns1.txt -l $TEST_FILE4 $TEST_FILE5" \
    "-f with -l"

run_test "-f -n combination" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns1.txt -n $TEST_FILE4" \
    "grep -f ${TEMP_DIR}/patterns1.txt -n $TEST_FILE4" \
    "-f with -n"

run_test "-f -h combination" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns1.txt -h $TEST_FILE4 $TEST_FILE5" \
    "grep -f ${TEMP_DIR}/patterns1.txt -h $TEST_FILE4 $TEST_FILE5" \
    "-f with -h"

run_test "-f -o combination" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns1.txt -o $TEST_FILE4" \
    "grep -f ${TEMP_DIR}/patterns1.txt -o $TEST_FILE4" \
    "-f with -o"

# -s with other flags
run_test "-s -i combination" \
    "$GREP_BIN -si error nonexistent.txt $TEST_FILE4" \
    "grep -si error nonexistent.txt $TEST_FILE4" \
    "-s with -i"

run_test "-s -v combination" \
    "$GREP_BIN -sv error nonexistent.txt $TEST_FILE4" \
    "grep -sv error nonexistent.txt $TEST_FILE4" \
    "-s with -v"

run_test "-s -c combination" \
    "$GREP_BIN -sc error nonexistent.txt $TEST_FILE4" \
    "grep -sc error nonexistent.txt $TEST_FILE4" \
    "-s with -c"

run_test "-s -l combination" \
    "$GREP_BIN -sl error nonexistent.txt $TEST_FILE4 $TEST_FILE5" \
    "grep -sl error nonexistent.txt $TEST_FILE4 $TEST_FILE5" \
    "-s with -l"

run_test "-s -n combination" \
    "$GREP_BIN -sn error nonexistent.txt $TEST_FILE4" \
    "grep -sn error nonexistent.txt $TEST_FILE4" \
    "-s with -n"

run_test "-s -h combination" \
    "$GREP_BIN -sh error nonexistent.txt $TEST_FILE4 $TEST_FILE5" \
    "grep -sh error nonexistent.txt $TEST_FILE4 $TEST_FILE5" \
    "-s with -h"

run_test "-s -o combination" \
    "$GREP_BIN -so error nonexistent.txt $TEST_FILE4" \
    "grep -so error nonexistent.txt $TEST_FILE4" \
    "-s with -o"

echo ""

# ##############################################################################
# SECTION 13: THREE-FLAG COMBINATIONS
# ##############################################################################

echo -e "${YELLOW}=== SECTION 13: Three-Flag Combinations ===${NC}"

run_simple_test "-i -v -n" "-ivn" "apple" "$TEST_FILE2" \
    "Case insensitive + invert + line numbers"

run_simple_test "-i -v -c" "-ivc" "apple" "$TEST_FILE2" \
    "Case insensitive + invert + count"

run_simple_test "-i -c -l" "-icl" "apple" "$TEST_FILE2 $TEST_FILE1" \
    "Case insensitive + count + list"

run_simple_test "-i -n -h" "-inh" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Case insensitive + line numbers + no filename"

run_simple_test "-i -n -o" "-ino" "error" "$TEST_FILE4" \
    "Case insensitive + line numbers + only match"

run_simple_test "-v -c -n" "-vcn" "apple" "$TEST_FILE2" \
    "Invert + count + line numbers"

run_simple_test "-v -n -h" "-vnh" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Invert + line numbers + no filename"

run_simple_test "-c -n -h" "-cnh" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Count + line numbers + no filename"

run_simple_test "-n -h -o" "-nho" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Line numbers + no filename + only match"

run_test "-f -i -n" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns1.txt -in $TEST_FILE4" \
    "grep -f ${TEMP_DIR}/patterns1.txt -in $TEST_FILE4" \
    "File patterns + case insensitive + line numbers"

run_test "-f -v -c" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns1.txt -vc $TEST_FILE4" \
    "grep -f ${TEMP_DIR}/patterns1.txt -vc $TEST_FILE4" \
    "File patterns + invert + count"

run_test "-f -l -h" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns1.txt -lh $TEST_FILE4 $TEST_FILE5" \
    "grep -f ${TEMP_DIR}/patterns1.txt -lh $TEST_FILE4 $TEST_FILE5" \
    "File patterns + list + no filename"

run_test "-e -e -i (two patterns + case insensitive)" \
    "$GREP_BIN -e apple -e banana -i $TEST_FILE2" \
    "grep -e apple -e banana -i $TEST_FILE2" \
    "Two -e patterns + case insensitive"

run_test "-e -e -n (two patterns + line numbers)" \
    "$GREP_BIN -e error -e warning -n $TEST_FILE4" \
    "grep -e error -e warning -n $TEST_FILE4" \
    "Two -e patterns + line numbers"

run_test "-e -e -c (two patterns + count)" \
    "$GREP_BIN -e error -e warning -c $TEST_FILE4" \
    "grep -e error -e warning -c $TEST_FILE4" \
    "Two -e patterns + count"

echo ""

# ##############################################################################
# SECTION 14: FOUR+ FLAG COMBINATIONS
# ##############################################################################

echo -e "${YELLOW}=== SECTION 14: Four+ Flag Combinations ===${NC}"

run_simple_test "-i -v -n -h" "-ivnh" "apple" "$TEST_FILE2 $TEST_FILE1" \
    "4 flags: case insensitive + invert + line num + no filename"

run_simple_test "-i -v -c -h" "-ivch" "apple" "$TEST_FILE2 $TEST_FILE1" \
    "4 flags: case insensitive + invert + count + no filename"

run_simple_test "-i -n -h -o" "-inho" "error" "$TEST_FILE4 $TEST_FILE5" \
    "4 flags: case insensitive + line num + no filename + only match"

run_test "-f -i -v -n" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns1.txt -ivn $TEST_FILE4" \
    "grep -f ${TEMP_DIR}/patterns1.txt -ivn $TEST_FILE4" \
    "4 flags: file + case insensitive + invert + line numbers"

run_test "-f -i -c -h" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns1.txt -ich $TEST_FILE4 $TEST_FILE5" \
    "grep -f ${TEMP_DIR}/patterns1.txt -ich $TEST_FILE4 $TEST_FILE5" \
    "4 flags: file + case insensitive + count + no filename"

run_test "-e -e -i -n -h (complex)" \
    "$GREP_BIN -e error -e warning -inh $TEST_FILE4 $TEST_FILE5" \
    "grep -e error -e warning -inh $TEST_FILE4 $TEST_FILE5" \
    "5 components: two -e + case insensitive + line num + no filename"

run_simple_test "-i -v -c -l -h" "-ivclh" "apple" "$TEST_FILE2 $TEST_FILE1" \
    "5 flags: all major flags combined"

echo ""

# ##############################################################################
# SECTION 15: FLAG PRIORITY AND INTERACTION
# ##############################################################################

echo -e "${YELLOW}=== SECTION 15: Flag Priority and Interaction ===${NC}"

# -c should suppress normal output
run_simple_test "-c suppresses normal output" "-c" "test" "$TEST_FILE1" \
    "-c flag should only output count"

# -l should suppress normal output
run_simple_test "-l suppresses normal output" "-l" "test" "$TEST_FILE1" \
    "-l flag should only output filenames"

# -l takes precedence over -c (based on grep behavior)
run_simple_test "-l vs -c priority" "-lc" "error" "$TEST_FILE4 $TEST_FILE5" \
    "-l should take precedence over -c"

run_simple_test "-c vs -l priority (reversed)" "-cl" "error" "$TEST_FILE4 $TEST_FILE5" \
    "-c before -l (same result expected)"

# -o should be ignored with -c
run_simple_test "-o ignored with -c" "-oc" "error" "$TEST_FILE4" \
    "-o should be ignored when -c is present"

# -o should be ignored with -l
run_simple_test "-o ignored with -l" "-ol" "error" "$TEST_FILE4 $TEST_FILE5" \
    "-o should be ignored when -l is present"

# -o should be ignored with -v (standard grep behavior)
run_simple_test "-o ignored with -v" "-ov" "apple" "$TEST_FILE2" \
    "-o should be ignored when -v is present"

# -n should be ignored with -c
run_simple_test "-n ignored with -c" "-nc" "error" "$TEST_FILE4" \
    "-n should be ignored when -c is present"

# -n should be ignored with -l
run_simple_test "-n ignored with -l" "-nl" "error" "$TEST_FILE4 $TEST_FILE5" \
    "-n should be ignored when -l is present"

# -h affects -c output for multiple files
run_simple_test "-h affects -c for multiple files" "-hc" "error" "$TEST_FILE4 $TEST_FILE5" \
    "-h should suppress filename in -c output"

# -h does not affect -l output
run_simple_test "-h with -l" "-hl" "error" "$TEST_FILE4 $TEST_FILE5" \
    "-h with -l (filenames still shown as they are the output)"

echo ""

# ##############################################################################
# SECTION 16: MULTIPLE FILES BEHAVIOR
# ##############################################################################

echo -e "${YELLOW}=== SECTION 16: Multiple Files Behavior ===${NC}"

run_simple_test "2 files - basic" "" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Two files - basic pattern matching"

run_simple_test "3 files - basic" "" "error" "$TEST_FILE3 $TEST_FILE4 $TEST_FILE5" \
    "Three files - basic pattern matching"

run_simple_test "4 files - mixed match" "" "error" "$TEST_FILE1 $TEST_FILE3 $TEST_FILE4 $TEST_FILE5" \
    "Four files - some without matches"

run_simple_test "2 files - with -n" "-n" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Two files with line numbers"

run_simple_test "3 files - with -c" "-c" "error" "$TEST_FILE3 $TEST_FILE4 $TEST_FILE5" \
    "Three files with count"

run_simple_test "3 files - with -l" "-l" "error" "$TEST_FILE1 $TEST_FILE4 $TEST_FILE5" \
    "Three files with -l (list)"

run_simple_test "Single file - no filename prefix" "" "test" "$TEST_FILE1" \
    "Single file - no filename prefix in output"

run_simple_test "Single file with -h" "-h" "test" "$TEST_FILE1" \
    "Single file with -h (no effect expected)"

# File order matters in output
run_simple_test "File order test A" "" "error" "$TEST_FILE4 $TEST_FILE5" \
    "File order - first order"

run_simple_test "File order test B" "" "error" "$TEST_FILE5 $TEST_FILE4" \
    "File order - reversed order"

echo ""

# ##############################################################################
# SECTION 17: MULTIPLE PATTERNS
# ##############################################################################

echo -e "${YELLOW}=== SECTION 17: Multiple Patterns ===${NC}"

run_test "Two -e patterns" \
    "$GREP_BIN -e error -e warning $TEST_FILE4" \
    "grep -e error -e warning $TEST_FILE4" \
    "Two patterns via -e"

run_test "Three -e patterns" \
    "$GREP_BIN -e error -e warning -e info $TEST_FILE4" \
    "grep -e error -e warning -e info $TEST_FILE4" \
    "Three patterns via -e"

run_test "Four -e patterns" \
    "$GREP_BIN -e one -e two -e three -e four $TEST_FILE8" \
    "grep -e one -e two -e three -e four $TEST_FILE8" \
    "Four patterns via -e"

run_test "-f with two patterns" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns1.txt $TEST_FILE4" \
    "grep -f ${TEMP_DIR}/patterns1.txt $TEST_FILE4" \
    "Pattern file with two patterns"

run_test "-f with three patterns" \
    "$GREP_BIN -f ${TEMP_DIR}/exact_patterns.txt $TEST_FILE6" \
    "grep -f ${TEMP_DIR}/exact_patterns.txt $TEST_FILE6" \
    "Pattern file with three patterns"

run_test "-e and -f combined" \
    "$GREP_BIN -e info -f ${TEMP_DIR}/patterns1.txt $TEST_FILE4" \
    "grep -e info -f ${TEMP_DIR}/patterns1.txt $TEST_FILE4" \
    "Mix -e and -f patterns"

run_test "Multiple -e with multiple files" \
    "$GREP_BIN -e error -e warning $TEST_FILE4 $TEST_FILE5" \
    "grep -e error -e warning $TEST_FILE4 $TEST_FILE5" \
    "Multiple -e patterns with multiple files"

echo ""

# ##############################################################################
# SECTION 18: REGEX PATTERNS
# ##############################################################################

# NOTE: s21_grep uses REG_EXTENDED (like grep -E), so we compare against grep
# for patterns that work the same in both basic and extended regex.

echo -e "${YELLOW}=== SECTION 18: Regex Patterns ===${NC}"

run_simple_test "Regex: dot any char" "" "a.c" "$TEST_FILE6" \
    "Regex dot (any char)"

run_simple_test "Regex: star quantifier" "" "ab*c" "$TEST_FILE6" \
    "Regex star quantifier"

run_simple_test "Regex: start anchor" "" "^a" "$TEST_FILE6" \
    "Regex caret (start of line)"

run_simple_test "Regex: end anchor" "" "c\$" "$TEST_FILE6" \
    "Regex dollar (end of line)"

run_simple_test "Regex: character class" "" "[abc]" "$TEST_FILE6" \
    "Regex character class"

run_simple_test "Regex: digit range" "" "[0-9]" "${TEMP_DIR}/digits.txt" \
    "Regex digit range"

run_simple_test "Regex: word pattern" "" "test[0-9]" "${TEMP_DIR}/numbered.txt" \
    "Regex word + digit pattern"

run_simple_test "Regex: complex with -n" "-n" "a.*c" "$TEST_FILE6" \
    "Complex regex with -n flag"

# Note: s21_grep uses REG_EXTENDED, so alternation uses | directly
# We compare with grep -E for extended regex patterns
run_test "Regex: alternation (extended)" \
    "$GREP_BIN 'abc|ac' $TEST_FILE6" \
    "grep -E 'abc|ac' $TEST_FILE6" \
    "Alternation with extended regex"

run_simple_test "Regex: bracket expression" "" "[a-c]" "$TEST_FILE6" \
    "Bracket expression range"

echo ""

# ##############################################################################
# SECTION 19: EDGE CASES AND CORNER CASES
# ##############################################################################

echo -e "${YELLOW}=== SECTION 19: Edge Cases and Corner Cases ===${NC}"

# Empty files
run_simple_test "Empty file - basic" "" "pattern" "$TEST_FILE9" \
    "Search in completely empty file"

run_simple_test "Empty file with -c" "-c" "pattern" "$TEST_FILE9" \
    "Count in empty file"

run_simple_test "Empty file with -l" "-l" "pattern" "$TEST_FILE9" \
    "List empty file (no match)"

run_simple_test "Empty file with -v" "-v" "pattern" "$TEST_FILE9" \
    "Invert match in empty file"

# Files with empty lines
run_simple_test "File with empty lines - basic" "" "Line" "$TEST_FILE7" \
    "Match in file with empty lines"

# Match empty lines - both basic and extended regex handle ^$ the same way
run_simple_test "File with empty lines - match empty" "" "^$" "$TEST_FILE7" \
    "Match empty lines only"

run_simple_test "File with empty lines - invert Line pattern" "-v" "Line" "$TEST_FILE7" \
    "Invert match Line pattern (shows empty lines)"

# File without trailing newline
run_simple_test "No trailing newline" "" "newline" "${TEMP_DIR}/no_newline.txt" \
    "File without trailing newline"

run_simple_test "No trailing newline - pattern at end" "" "end" "${TEMP_DIR}/no_newline.txt" \
    "Match at end of file without newline"

# Single line file
run_simple_test "Single line file - match" "" "only" "${TEMP_DIR}/single_line.txt" \
    "Match in single line file"

run_simple_test "Single line file - no match" "" "nonexistent" "${TEMP_DIR}/single_line.txt" \
    "No match in single line file"

run_simple_test "Single line file with -n" "-n" "only" "${TEMP_DIR}/single_line.txt" \
    "Single line file with line numbers"

run_simple_test "Single line file with -c" "-c" "only" "${TEMP_DIR}/single_line.txt" \
    "Single line file with count"

# Pattern not found
run_simple_test "Pattern not found - single file" "" "xyz123nonexistent" "$TEST_FILE1" \
    "Pattern not found (exit code 1)"

run_simple_test "Pattern not found - multiple files" "" "xyz123nonexistent" "$TEST_FILE1 $TEST_FILE2" \
    "Pattern not found in any file"

# Special characters in pattern
run_simple_test "Pattern with spaces" "" "Line 1" "$TEST_FILE7" \
    "Pattern containing spaces"

run_simple_test "Pattern with common chars" "" "abc" "${TEMP_DIR}/incremental.txt" \
    "Simple pattern match"

# Multiple matches on same line
run_simple_test "Multiple matches per line" "" "match" "${TEMP_DIR}/multi_match.txt" \
    "Line with multiple matches"

run_simple_test "Multiple matches per line with -o" "-o" "match" "${TEMP_DIR}/multi_match.txt" \
    "Line with multiple matches using -o"

run_simple_test "Multiple matches per line with -c" "-c" "match" "${TEMP_DIR}/multi_match.txt" \
    "Count lines (not matches) with multiple matches"

# Duplicate lines in file
run_simple_test "Duplicate lines" "" "bbb" "${TEMP_DIR}/duplicates.txt" \
    "Match duplicate lines"

run_simple_test "Duplicate lines with -c" "-c" "bbb" "${TEMP_DIR}/duplicates.txt" \
    "Count duplicate lines"

echo ""

# ##############################################################################
# SECTION 20: EXIT CODES
# ##############################################################################

echo -e "${YELLOW}=== SECTION 20: Exit Codes ===${NC}"

# Test exit code 0 (matches found)
s21_exit=$($GREP_BIN "test" "$TEST_FILE1" > /dev/null 2>&1; echo $?)
grep_exit=$(grep "test" "$TEST_FILE1" > /dev/null 2>&1; echo $?)
TOTAL=$((TOTAL + 1))
if [ "$s21_exit" = "$grep_exit" ] && [ "$s21_exit" = "0" ]; then
    echo -e "${GREEN}[PASS]${NC} Test $TOTAL: Exit code 0 (match found)"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}[FAIL]${NC} Test $TOTAL: Exit code 0 (match found)"
    echo "  s21_exit: $s21_exit, grep_exit: $grep_exit (expected 0)"
    FAILED=$((FAILED + 1))
    FAILED_TESTS+=("Exit code 0")
fi

# Test exit code 1 (no matches found)
s21_exit=$($GREP_BIN "nonexistent_xyz" "$TEST_FILE1" > /dev/null 2>&1; echo $?)
grep_exit=$(grep "nonexistent_xyz" "$TEST_FILE1" > /dev/null 2>&1; echo $?)
TOTAL=$((TOTAL + 1))
if [ "$s21_exit" = "$grep_exit" ] && [ "$s21_exit" = "1" ]; then
    echo -e "${GREEN}[PASS]${NC} Test $TOTAL: Exit code 1 (no match)"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}[FAIL]${NC} Test $TOTAL: Exit code 1 (no match)"
    echo "  s21_exit: $s21_exit, grep_exit: $grep_exit (expected 1)"
    FAILED=$((FAILED + 1))
    FAILED_TESTS+=("Exit code 1")
fi

# Test exit code with -l (0 when match found)
s21_exit=$($GREP_BIN -l "test" "$TEST_FILE1" > /dev/null 2>&1; echo $?)
grep_exit=$(grep -l "test" "$TEST_FILE1" > /dev/null 2>&1; echo $?)
TOTAL=$((TOTAL + 1))
if [ "$s21_exit" = "$grep_exit" ]; then
    echo -e "${GREEN}[PASS]${NC} Test $TOTAL: Exit code with -l (match found)"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}[FAIL]${NC} Test $TOTAL: Exit code with -l (match found)"
    echo "  s21_exit: $s21_exit, grep_exit: $grep_exit"
    FAILED=$((FAILED + 1))
    FAILED_TESTS+=("Exit code -l match")
fi

# Test exit code with -l (1 when no match)
s21_exit=$($GREP_BIN -l "nonexistent_xyz" "$TEST_FILE1" > /dev/null 2>&1; echo $?)
grep_exit=$(grep -l "nonexistent_xyz" "$TEST_FILE1" > /dev/null 2>&1; echo $?)
TOTAL=$((TOTAL + 1))
if [ "$s21_exit" = "$grep_exit" ]; then
    echo -e "${GREEN}[PASS]${NC} Test $TOTAL: Exit code with -l (no match)"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}[FAIL]${NC} Test $TOTAL: Exit code with -l (no match)"
    echo "  s21_exit: $s21_exit, grep_exit: $grep_exit"
    FAILED=$((FAILED + 1))
    FAILED_TESTS+=("Exit code -l no match")
fi

# Test exit code with -c
s21_exit=$($GREP_BIN -c "test" "$TEST_FILE1" > /dev/null 2>&1; echo $?)
grep_exit=$(grep -c "test" "$TEST_FILE1" > /dev/null 2>&1; echo $?)
TOTAL=$((TOTAL + 1))
if [ "$s21_exit" = "$grep_exit" ]; then
    echo -e "${GREEN}[PASS]${NC} Test $TOTAL: Exit code with -c"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}[FAIL]${NC} Test $TOTAL: Exit code with -c"
    echo "  s21_exit: $s21_exit, grep_exit: $grep_exit"
    FAILED=$((FAILED + 1))
    FAILED_TESTS+=("Exit code -c")
fi

# Test exit code with -v (invert creates matches)
s21_exit=$($GREP_BIN -v "nonexistent_xyz" "$TEST_FILE1" > /dev/null 2>&1; echo $?)
grep_exit=$(grep -v "nonexistent_xyz" "$TEST_FILE1" > /dev/null 2>&1; echo $?)
TOTAL=$((TOTAL + 1))
if [ "$s21_exit" = "$grep_exit" ] && [ "$s21_exit" = "0" ]; then
    echo -e "${GREEN}[PASS]${NC} Test $TOTAL: Exit code with -v (all lines match)"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}[FAIL]${NC} Test $TOTAL: Exit code with -v (all lines match)"
    echo "  s21_exit: $s21_exit, grep_exit: $grep_exit (expected 0)"
    FAILED=$((FAILED + 1))
    FAILED_TESTS+=("Exit code -v match")
fi

echo ""

# ##############################################################################
# SECTION 21: LONG OPTION NAMES
# ##############################################################################

echo -e "${YELLOW}=== SECTION 21: Long Option Names ===${NC}"

run_test "--regexp" \
    "$GREP_BIN --regexp=test $TEST_FILE1" \
    "grep --regexp=test $TEST_FILE1" \
    "Long option --regexp"

run_test "--ignore-case" \
    "$GREP_BIN --ignore-case apple $TEST_FILE2" \
    "grep --ignore-case apple $TEST_FILE2" \
    "Long option --ignore-case"

run_test "--invert-match" \
    "$GREP_BIN --invert-match apple $TEST_FILE2" \
    "grep --invert-match apple $TEST_FILE2" \
    "Long option --invert-match"

run_test "--count" \
    "$GREP_BIN --count error $TEST_FILE4" \
    "grep --count error $TEST_FILE4" \
    "Long option --count"

run_test "--files-with-matches" \
    "$GREP_BIN --files-with-matches error $TEST_FILE4 $TEST_FILE5" \
    "grep --files-with-matches error $TEST_FILE4 $TEST_FILE5" \
    "Long option --files-with-matches"

run_test "--line-number" \
    "$GREP_BIN --line-number error $TEST_FILE4" \
    "grep --line-number error $TEST_FILE4" \
    "Long option --line-number"

run_test "--no-filename" \
    "$GREP_BIN --no-filename error $TEST_FILE4 $TEST_FILE5" \
    "grep --no-filename error $TEST_FILE4 $TEST_FILE5" \
    "Long option --no-filename"

run_test "--no-messages" \
    "$GREP_BIN --no-messages error nonexistent.txt $TEST_FILE4" \
    "grep --no-messages error nonexistent.txt $TEST_FILE4" \
    "Long option --no-messages"

run_test "--file" \
    "$GREP_BIN --file=${TEMP_DIR}/patterns1.txt $TEST_FILE4" \
    "grep --file=${TEMP_DIR}/patterns1.txt $TEST_FILE4" \
    "Long option --file"

run_test "--only-matching" \
    "$GREP_BIN --only-matching error $TEST_FILE4" \
    "grep --only-matching error $TEST_FILE4" \
    "Long option --only-matching"

run_test "Mixed long and short options" \
    "$GREP_BIN --ignore-case -n apple $TEST_FILE2" \
    "grep --ignore-case -n apple $TEST_FILE2" \
    "Mixed long and short options"

echo ""

# ##############################################################################
# SECTION 22: COMBINED SHORT FLAGS
# ##############################################################################

echo -e "${YELLOW}=== SECTION 22: Combined Short Flags ===${NC}"

run_simple_test "Combined -in" "-in" "apple" "$TEST_FILE2" \
    "Combined -in"

run_simple_test "Combined -iv" "-iv" "apple" "$TEST_FILE2" \
    "Combined -iv"

run_simple_test "Combined -ic" "-ic" "apple" "$TEST_FILE2" \
    "Combined -ic"

run_simple_test "Combined -vn" "-vn" "apple" "$TEST_FILE2" \
    "Combined -vn"

run_simple_test "Combined -vc" "-vc" "apple" "$TEST_FILE2" \
    "Combined -vc"

run_simple_test "Combined -nc" "-nc" "error" "$TEST_FILE4" \
    "Combined -nc"

run_simple_test "Combined -nh" "-nh" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Combined -nh"

run_simple_test "Combined -ch" "-ch" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Combined -ch"

run_simple_test "Combined -lh" "-lh" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Combined -lh"

run_simple_test "Combined -no" "-no" "error" "$TEST_FILE4" \
    "Combined -no"

run_simple_test "Combined -ho" "-ho" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Combined -ho"

run_simple_test "Combined -ivn" "-ivn" "apple" "$TEST_FILE2" \
    "Combined -ivn"

run_simple_test "Combined -ivc" "-ivc" "apple" "$TEST_FILE2" \
    "Combined -ivc"

run_simple_test "Combined -inh" "-inh" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Combined -inh"

run_simple_test "Combined -vnh" "-vnh" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Combined -vnh"

run_simple_test "Combined -nho" "-nho" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Combined -nho"

echo ""

# ##############################################################################
# SECTION 23: SPECIAL PATTERN CASES
# ##############################################################################

echo -e "${YELLOW}=== SECTION 23: Special Pattern Cases ===${NC}"

# Empty pattern (matches all lines)
run_test "Empty pattern" \
    "$GREP_BIN -e '' $TEST_FILE1" \
    "grep -e '' $TEST_FILE1" \
    "Empty pattern should match all lines"

# Pattern with only whitespace
run_simple_test "Pattern with space" "" " " "${TEMP_DIR}/spaces.txt" \
    "Pattern is a single space"

run_simple_test "Pattern with tab" "" "	" "$DATA_DIR/tabs_spaces.txt" \
    "Pattern is a tab character"

# Very long pattern
run_simple_test "Long pattern that doesn't match" "" "this_is_a_very_long_pattern_xyz" "$TEST_FILE1" \
    "Very long pattern (no match)"

# Pattern is entire line
run_simple_test "Pattern is entire line" "" "Hello world" "$TEST_FILE1" \
    "Pattern matches entire line content"

# Pattern with newline-like content
run_simple_test "Pattern starting with caret" "" "^Line" "$TEST_FILE7" \
    "Pattern starting with caret"

run_simple_test "Pattern ending with dollar" "" "only_one_line" "${TEMP_DIR}/single_line.txt" \
    "Pattern at end of line"

echo ""

# ##############################################################################
# SECTION 24: BOUNDARY CONDITIONS
# ##############################################################################

echo -e "${YELLOW}=== SECTION 24: Boundary Conditions ===${NC}"

# First line match
run_simple_test "Match first line only" "-n" "Hello" "$TEST_FILE1" \
    "Pattern on first line"

# Last line match
run_simple_test "Match last line only" "-n" "END" "$TEST_FILE1" \
    "Pattern on last line"

# Match all lines
run_simple_test "Match all lines" "-c" "." "$TEST_FILE1" \
    "Regex . matches all lines"

# Match no lines with pattern not in file  
run_simple_test "Match no lines" "-c" "zzzzzzz" "$TEST_FILE1" \
    "Pattern not in file (count zero)"

# Single character file
echo "x" > "${TEMP_DIR}/single_char.txt"
run_simple_test "Single character file" "" "x" "${TEMP_DIR}/single_char.txt" \
    "File with single character"

run_simple_test "Single character file with -n" "-n" "x" "${TEMP_DIR}/single_char.txt" \
    "Single char file with line number"

# Many small files
run_simple_test "Many files (5)" "" "error" "$TEST_FILE3 $TEST_FILE4 $TEST_FILE5 $TEST_FILE4 $TEST_FILE5" \
    "Five files with pattern"

run_simple_test "Many files with -c (5)" "-c" "error" "$TEST_FILE3 $TEST_FILE4 $TEST_FILE5 $TEST_FILE4 $TEST_FILE5" \
    "Five files with count"

echo ""

# ##############################################################################
# SECTION 25: COMPREHENSIVE FLAG MATRIX TESTS
# ##############################################################################

echo -e "${YELLOW}=== SECTION 25: Comprehensive Flag Matrix ===${NC}"

# All possible pairs not yet covered
run_simple_test "Pair: -e -s" "-s" "error" "nonexistent.txt $TEST_FILE4" \
    "-e implicit with -s"

run_test "Pair: -f -s" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns1.txt -s nonexistent.txt $TEST_FILE4" \
    "grep -f ${TEMP_DIR}/patterns1.txt -s nonexistent.txt $TEST_FILE4" \
    "-f with -s"

# Test all flags together (where applicable)
run_simple_test "All applicable flags: -i -n -h -o" "-inho" "error" "$TEST_FILE4 $TEST_FILE5" \
    "Multiple non-conflicting flags"

run_test "Pattern from file + all output mods" \
    "$GREP_BIN -f ${TEMP_DIR}/patterns1.txt -inh $TEST_FILE4 $TEST_FILE5" \
    "grep -f ${TEMP_DIR}/patterns1.txt -inh $TEST_FILE4 $TEST_FILE5" \
    "Pattern file with multiple flags"

run_test "Multiple -e + output mods" \
    "$GREP_BIN -e error -e warning -nh $TEST_FILE4 $TEST_FILE5" \
    "grep -e error -e warning -nh $TEST_FILE4 $TEST_FILE5" \
    "Multiple patterns with output modifications"

echo ""

# ##############################################################################
# SECTION 26: STRESS TESTS
# ##############################################################################

echo -e "${YELLOW}=== SECTION 26: Stress Tests ===${NC}"

# Create larger test file
for i in $(seq 1 100); do
    echo "Line $i: This is a test line with some content"
done > "${TEMP_DIR}/large_file.txt"

run_simple_test "Large file (100 lines)" "" "test" "${TEMP_DIR}/large_file.txt" \
    "Search in larger file"

run_simple_test "Large file with -c" "-c" "Line" "${TEMP_DIR}/large_file.txt" \
    "Count in larger file"

run_simple_test "Large file with -n" "-n" "Line 50" "${TEMP_DIR}/large_file.txt" \
    "Line numbers in larger file"

run_simple_test "Large file with -o" "-o" "Line" "${TEMP_DIR}/large_file.txt" \
    "Only matching in larger file"

# Many patterns
run_test "Many -e patterns (5)" \
    "$GREP_BIN -e Line -e test -e content -e some -e with ${TEMP_DIR}/large_file.txt" \
    "grep -e Line -e test -e content -e some -e with ${TEMP_DIR}/large_file.txt" \
    "Five patterns via -e"

echo ""

# ##############################################################################
# SECTION 27: ERROR HANDLING
# ##############################################################################

echo -e "${YELLOW}=== SECTION 27: Error Handling ===${NC}"

# Multiple nonexistent files with -s
run_test "Multiple nonexistent with -s" \
    "$GREP_BIN -s pattern nonexistent1.txt nonexistent2.txt nonexistent3.txt" \
    "grep -s pattern nonexistent1.txt nonexistent2.txt nonexistent3.txt" \
    "Suppress errors for multiple nonexistent files"

# Mix of existing and nonexistent with -s
run_test "Mix exist/nonexist with -s (2)" \
    "$GREP_BIN -s error $TEST_FILE4 nonexistent.txt $TEST_FILE5" \
    "grep -s error $TEST_FILE4 nonexistent.txt $TEST_FILE5" \
    "Mixed files with suppressed errors"

# Pattern file that doesn't exist (should error, not suppressed by -s for pattern file)
# Test that -f with nonexistent file produces an error (message format may differ)
# TOTAL=$((TOTAL + 1))
# s21_err=$($GREP_BIN -f nonexistent_pattern_file.txt $TEST_FILE1 2>&1)
# s21_exit=$?
# grep_err=$(grep -f nonexistent_pattern_file.txt $TEST_FILE1 2>&1)
# grep_exit=$?
# # Both should output an error message to stderr and have exit code 2
# if [ -n "$s21_err" ] && [ -n "$grep_err" ] && [ "$s21_exit" = "$grep_exit" ]; then
#     echo -e "${GREEN}[PASS]${NC} Test $TOTAL: -f with nonexistent pattern file"
#     PASSED=$((PASSED + 1))
# else
#     echo -e "${RED}[FAIL]${NC} Test $TOTAL: -f with nonexistent pattern file"
#     echo "  s21_grep exit: $s21_exit, grep exit: $grep_exit"
#     echo "  s21_grep error: $s21_err"
#     echo "  grep error: $grep_err"
#     FAILED=$((FAILED + 1))
#     FAILED_TESTS+=("-f with nonexistent pattern file")
# fi

echo ""

# ##############################################################################
# SUMMARY
# ##############################################################################

echo ""
echo "=========================================================================="
echo -e "${BLUE}                    TEST SUMMARY${NC}"
echo "=========================================================================="
echo ""
echo "Total tests run: $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"

if [ $FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}Failed tests:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}- $test${NC}"
    done
    echo ""
    PASS_PERCENT=$((PASSED * 100 / TOTAL))
    echo -e "${YELLOW}Pass rate: ${PASS_PERCENT}%${NC}"
    exit 1
else
    echo ""
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
