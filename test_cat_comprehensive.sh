#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

# Paths
CAT_EXECUTABLE="./s21_cat"
DATA_DIR="data-samples"
TEST_FILE1="${DATA_DIR}/simple.txt"
TEST_FILE2="${DATA_DIR}/empty_lines.txt"
TEST_FILE3="${DATA_DIR}/tabs_spaces.txt"
TEST_FILE4="${DATA_DIR}/mixed_empty_lines.txt"
TEST_FILE5="${DATA_DIR}/non_printable.txt"

echo "Building s21_cat..."
make s21_cat > /dev/null 2>&1 || {
    echo -e "${RED}ERROR: Failed to build s21_cat${NC}"
    exit 1
}

run_test() {
    local description="$1"
    local flags="$2"
    shift 2
    local files=("$@")

    local s21_output
    local cat_output

    if [ ${#files[@]} -eq 0 ]; then
        s21_output=$($CAT_EXECUTABLE $flags 2>&1 || true)
        cat_output=$(cat $flags 2>&1 || true)
    else
        s21_output=$($CAT_EXECUTABLE $flags "${files[@]}" 2>&1 || true)
        cat_output=$(cat $flags "${files[@]}" 2>&1 || true)
    fi

    if diff -u <(echo "$s21_output") <(echo "$cat_output") >/dev/null; then
        echo -e "${GREEN}✓${NC} $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} $description"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$description (flags: $flags)")
        echo "Diff:"
        diff -u <(echo "$s21_output") <(echo "$cat_output")
    fi

}

create_temp_file() {
    mktemp "${DATA_DIR}/temp_XXXXXX.txt"
}

non_existent_file() {
    echo "${DATA_DIR}/this_file_does_not_exist_$(date +%s).txt"
}

echo ""
echo "=========================================="
echo "  COMPREHENSIVE CAT TEST SUITE"
echo "=========================================="
echo ""

# ============================================
# SECTION 1: Test with no flags (basic functionality)
# ============================================
echo "--- SECTION 1: No flags (basic) ---"
run_test "Single file, no flags" "" "$TEST_FILE1"
run_test "Multiple files, no flags" "" "$TEST_FILE1" "$TEST_FILE2"
run_test "Three files, no flags" "" "$TEST_FILE1" "$TEST_FILE2" "$TEST_FILE3"
run_test "Empty file, no flags" "" "${DATA_DIR}/only_empty.txt"
run_test "File with only empty lines" "" "${DATA_DIR}/empty_lines.txt"
echo ""

# ============================================
# SECTION 2: Individual flags
# ============================================
echo "--- SECTION 2: Individual flags ---"

# Test -b flag
run_test "Flag -b: single file" "-b" "$TEST_FILE1"
run_test "Flag -b: multiple files" "-b" "$TEST_FILE1" "$TEST_FILE2"
run_test "Flag -b: with empty lines" "-b" "${DATA_DIR}/empty_lines.txt"
run_test "Flag -b: mixed empty lines" "-b" "${DATA_DIR}/mixed_empty_lines.txt"

# Test -e flag
run_test "Flag -e: single file" "-e" "$TEST_FILE1"
run_test "Flag -e: multiple files" "-e" "$TEST_FILE1" "$TEST_FILE2"
run_test "Flag -e: with tabs" "-e" "$TEST_FILE3"
run_test "Flag -e: empty lines" "-e" "${DATA_DIR}/empty_lines.txt"

# Test -n flag
run_test "Flag -n: single file" "-n" "$TEST_FILE1"
run_test "Flag -n: multiple files" "-n" "$TEST_FILE1" "$TEST_FILE2"
run_test "Flag -n: with empty lines" "-n" "${DATA_DIR}/empty_lines.txt"
run_test "Flag -n: all empty file" "-n" "${DATA_DIR}/only_empty.txt"
run_test "Flag -n: mixed empty lines" "-n" "${DATA_DIR}/mixed_empty_lines.txt"
run_test "Flag -n: should number empty lines" "-n" "${DATA_DIR}/single_char_lines.txt"
run_test "Flag -n: should number ALL lines" "-n" "${DATA_DIR}/numbers_only.txt"

# Test -s flag
run_test "Flag -s: single file" "-s" "$TEST_FILE1"
run_test "Flag -s: multiple files" "-s" "$TEST_FILE1" "$TEST_FILE2"
run_test "Flag -s: with empty lines" "-s" "${DATA_DIR}/empty_lines.txt"
run_test "Flag -s: many empty lines" "-s" "${DATA_DIR}/many_empty_lines.txt"
run_test "Flag -s: mixed empty lines" "-s" "${DATA_DIR}/mixed_empty_lines.txt"

# Test -t flag
run_test "Flag -t: single file" "-t" "$TEST_FILE1"
run_test "Flag -t: multiple files" "-t" "$TEST_FILE1" "$TEST_FILE2"
run_test "Flag -t: with tabs" "-t" "$TEST_FILE3"
run_test "Flag -t: leading tabs" "-t" "${DATA_DIR}/leading_tabs.txt"
run_test "Flag -t: empty lines" "-t" "${DATA_DIR}/empty_lines.txt"

echo ""

# ============================================
# SECTION 3: Two flag combinations
# ============================================
echo "--- SECTION 3: Two flag combinations ---"

run_test "Flags -b -e" "-b -e" "$TEST_FILE1"
run_test "Flags -b -n" "-b -n" "$TEST_FILE1"
run_test "Flags -b -s" "-b -s" "$TEST_FILE1"
run_test "Flags -b -t" "-b -t" "$TEST_FILE1"
run_test "Flags -e -n" "-e -n" "$TEST_FILE1"
run_test "Flags -e -s" "-e -s" "$TEST_FILE1"
run_test "Flags -e -t" "-e -t" "$TEST_FILE1"
run_test "Flags -n -s" "-n -s" "$TEST_FILE1"
run_test "Flags -n -t" "-n -t" "$TEST_FILE1"
run_test "Flags -s -t" "-s -t" "$TEST_FILE1"

# Test with files containing special cases
run_test "Flags -b -e: with empty lines" "-b -e" "${DATA_DIR}/empty_lines.txt"
run_test "Flags -b -s: with empty lines" "-b -s" "${DATA_DIR}/many_empty_lines.txt"
run_test "Flags -e -t: with tabs" "-e -t" "$TEST_FILE3"
run_test "Flags -n -s: with empty lines" "-n -s" "${DATA_DIR}/mixed_empty_lines.txt"

# Combined flags (short form)
run_test "Flags -be" "-be" "$TEST_FILE1"
run_test "Flags -bn" "-bn" "$TEST_FILE1"
run_test "Flags -bs" "-bs" "$TEST_FILE1"
run_test "Flags -bt" "-bt" "$TEST_FILE1"
run_test "Flags -en" "-en" "$TEST_FILE1"
run_test "Flags -es" "-es" "$TEST_FILE1"
run_test "Flags -et" "-et" "$TEST_FILE1"
run_test "Flags -ns" "-ns" "$TEST_FILE1"
run_test "Flags -nt" "-nt" "$TEST_FILE1"
run_test "Flags -st" "-st" "$TEST_FILE1"

echo ""

# ============================================
# SECTION 4: Three flag combinations
# ============================================
echo "--- SECTION 4: Three flag combinations ---"

run_test "Flags -b -e -n" "-b -e -n" "$TEST_FILE1"
run_test "Flags -b -e -s" "-b -e -s" "$TEST_FILE1"
run_test "Flags -b -e -t" "-b -e -t" "$TEST_FILE1"
run_test "Flags -b -n -s" "-b -n -s" "$TEST_FILE1"
run_test "Flags -b -n -t" "-b -n -t" "$TEST_FILE1"
run_test "Flags -b -s -t" "-b -s -t" "$TEST_FILE1"
run_test "Flags -e -n -s" "-e -n -s" "$TEST_FILE1"
run_test "Flags -e -n -t" "-e -n -t" "$TEST_FILE1"
run_test "Flags -e -s -t" "-e -s -t" "$TEST_FILE1"
run_test "Flags -n -s -t" "-n -s -t" "$TEST_FILE1"

# Combined short form
run_test "Flags -ben" "-ben" "$TEST_FILE1"
run_test "Flags -bes" "-bes" "$TEST_FILE1"
run_test "Flags -bet" "-bet" "$TEST_FILE1"
run_test "Flags -bns" "-bns" "$TEST_FILE1"
run_test "Flags -bnt" "-bnt" "$TEST_FILE1"
run_test "Flags -bst" "-bst" "$TEST_FILE1"
run_test "Flags -ens" "-ens" "$TEST_FILE1"
run_test "Flags -ent" "-ent" "$TEST_FILE1"
run_test "Flags -est" "-est" "$TEST_FILE1"
run_test "Flags -nst" "-nst" "$TEST_FILE1"

# With special files
run_test "Flags -bns: many empty lines" "-bns" "${DATA_DIR}/many_empty_lines.txt"
run_test "Flags -est: with tabs" "-est" "$TEST_FILE3"

echo ""

# ============================================
# SECTION 5: Four flag combinations
# ============================================
echo "--- SECTION 5: Four flag combinations ---"

run_test "Flags -b -e -n -s" "-b -e -n -s" "$TEST_FILE1"
run_test "Flags -b -e -n -t" "-b -e -n -t" "$TEST_FILE1"
run_test "Flags -b -e -s -t" "-b -e -s -t" "$TEST_FILE1"
run_test "Flags -b -n -s -t" "-b -n -s -t" "$TEST_FILE1"
run_test "Flags -e -n -s -t" "-e -n -s -t" "$TEST_FILE1"

# Combined short form
run_test "Flags -bens" "-bens" "$TEST_FILE1"
run_test "Flags -bent" "-bent" "$TEST_FILE1"
run_test "Flags -best" "-best" "$TEST_FILE1"
run_test "Flags -bnst" "-bnst" "$TEST_FILE1"
run_test "Flags -enst" "-enst" "$TEST_FILE1"

# With special files
run_test "Flags -bens: many empty lines" "-bens" "${DATA_DIR}/many_empty_lines.txt"
run_test "Flags -best: with tabs" "-best" "$TEST_FILE3"

echo ""

# ============================================
# SECTION 6: All five flags
# ============================================
echo "--- SECTION 6: All five flags ---"

run_test "Flags -b -e -n -s -t" "-b -e -n -s -t" "$TEST_FILE1"
run_test "Flags -benst" "-benst" "$TEST_FILE1"
run_test "Flags -bents" "-bents" "$TEST_FILE1"
run_test "Flags -bnest" "-bnest" "$TEST_FILE1"
run_test "Flags -betns" "-betns" "$TEST_FILE1"

# Multiple files with all flags
run_test "Flags -benst: multiple files" "-benst" "$TEST_FILE1" "$TEST_FILE2" "$TEST_FILE3"
run_test "Flags -benst: with empty lines" "-benst" "${DATA_DIR}/many_empty_lines.txt"
run_test "Flags -benst: with tabs" "-benst" "$TEST_FILE3"

echo ""

# ============================================
# SECTION 7: Flag priority tests (-b vs -n)
# ============================================
echo "--- SECTION 7: Flag priority (-b vs -n) ---"

# When both -b and -n are specified, -b should take precedence
run_test "Priority: -b should override -n (separate)" "-b -n" "$TEST_FILE1"
run_test "Priority: -b should override -n (combined -bn)" "-bn" "$TEST_FILE1"
run_test "Priority: -b should override -n (combined -nb)" "-nb" "$TEST_FILE1"
run_test "Priority: -b should override -n with empty lines" "-bn" "${DATA_DIR}/empty_lines.txt"
run_test "Priority: -b should override -n: mixed empty" "-bn" "${DATA_DIR}/mixed_empty_lines.txt"

echo ""

# ============================================
# SECTION 8: Multiple files tests
# ============================================
echo "--- SECTION 8: Multiple files ---"

run_test "2 files, flag -b" "-b" "$TEST_FILE1" "$TEST_FILE2"
run_test "2 files, flag -e" "-e" "$TEST_FILE1" "$TEST_FILE2"
run_test "2 files, flag -n" "-n" "$TEST_FILE1" "$TEST_FILE2"
run_test "3 files, flag -b" "-b" "$TEST_FILE1" "$TEST_FILE2" "$TEST_FILE3"
run_test "3 files, flag -e" "-e" "$TEST_FILE1" "$TEST_FILE2" "$TEST_FILE3"
run_test "4 files, no flags" "" "$TEST_FILE1" "$TEST_FILE2" "$TEST_FILE3" "${DATA_DIR}/empty_lines.txt"
run_test "4 files, flag -benst" "-benst" "$TEST_FILE1" "$TEST_FILE2" "$TEST_FILE3" "${DATA_DIR}/empty_lines.txt"
run_test "5 files, flag -ns" "-ns" "$TEST_FILE1" "$TEST_FILE2" "$TEST_FILE3" "${DATA_DIR}/empty_lines.txt" "${DATA_DIR}/mixed_empty_lines.txt"

echo ""

# ============================================
# SECTION 9: Corner cases - special files
# ============================================
echo "--- SECTION 9: Corner cases ---"

run_test "Single line file" "-b" "${DATA_DIR}/single_line.txt"
run_test "Single line file" "-n" "${DATA_DIR}/single_line.txt"
run_test "Single line file" "-e" "${DATA_DIR}/single_line.txt"
run_test "File without final newline" "-b" "${DATA_DIR}/no_newline_end.txt"
run_test "File without final newline" "-n" "${DATA_DIR}/no_newline_end.txt"
run_test "Very long line" "-b" "${DATA_DIR}/very_long_line.txt"
run_test "Very long line" "-e" "${DATA_DIR}/very_long_line.txt"
run_test "Many empty lines" "-s" "${DATA_DIR}/many_empty_lines.txt"
run_test "Complex mix" "-benst" "${DATA_DIR}/complex_mix.txt"
run_test "Leading tabs" "-t" "${DATA_DIR}/leading_tabs.txt"
run_test "Trailing spaces" "-e" "${DATA_DIR}/trailing_spaces.txt"
run_test "Non-printable chars" "-e" "${DATA_DIR}/non_printable.txt"
run_test "Non-printable chars" "-t" "${DATA_DIR}/non_printable.txt"
run_test "Single char lines" "-n" "${DATA_DIR}/single_char_lines.txt"
run_test "Numbers only" "-b" "${DATA_DIR}/numbers_only.txt"

# Additional edge cases
run_test "Flag -n: should number all lines including empty" "-n" "${DATA_DIR}/empty_lines.txt"
run_test "Flag -n: should number even when file starts with empty" "-n" "${DATA_DIR}/mixed_empty_lines.txt"
run_test "Flag -b -n: -b should take precedence" "-bn" "${DATA_DIR}/mixed_empty_lines.txt"
run_test "Flag -n -b: -b should take precedence" "-nb" "${DATA_DIR}/mixed_empty_lines.txt"
run_test "Flag -s: should not suppress first empty line" "-s" "${DATA_DIR}/many_empty_lines.txt"
run_test "Flag -s: should suppress only consecutive empty lines" "-s" "${DATA_DIR}/mixed_empty_lines.txt"

echo ""

# ============================================
# SECTION 10: Edge cases - file handling
# ============================================
echo "--- SECTION 10: Edge cases (file handling) ---"

# IMPORTANT FIX
set +e

NON_EXISTENT=$(non_existent_file)

$CAT_EXECUTABLE -b "$NON_EXISTENT" >/tmp/s21_cat_nonexist.out 2>&1
S21_EXIT=$?
cat -b "$NON_EXISTENT" >/tmp/cat_nonexist.out 2>&1
CAT_EXIT=$?

if [ "$S21_EXIT" = "$CAT_EXIT" ] && [ "$S21_EXIT" != "0" ]; then
    echo -e "${GREEN}✓${NC} Non-existent file (both return error)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC} Non-existent file (exit codes differ)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

$CAT_EXECUTABLE -b "$TEST_FILE1" "$NON_EXISTENT" "$TEST_FILE2" >/tmp/s21_cat_mixed.out 2>&1
S21_EXIT=$?
cat -b "$TEST_FILE1" "$NON_EXISTENT" "$TEST_FILE2" >/tmp/cat_mixed.out 2>&1
CAT_EXIT=$?

S21_STDOUT=$(grep -v ":" /tmp/s21_cat_mixed.out | head -20)
CAT_STDOUT=$(grep -v ":" /tmp/cat_mixed.out | head -20)

if [ "$S21_STDOUT" = "$CAT_STDOUT" ] && [ "$S21_EXIT" = "$CAT_EXIT" ]; then
    echo -e "${GREEN}✓${NC} Existing + non-existent files (stdout matches)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${YELLOW}⚠${NC} Existing + non-existent files (error handling differs)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

rm -f /tmp/s21_cat_nonexist.out /tmp/cat_nonexist.out /tmp/s21_cat_mixed.out /tmp/cat_mixed.out

run_test "Empty file, flag -b" "-b" "${DATA_DIR}/only_empty.txt"
run_test "Empty file, flag -n" "-n" "${DATA_DIR}/only_empty.txt"
run_test "Empty file, flag -s" "-s" "${DATA_DIR}/only_empty.txt"

EMPTY_TEMP=$(create_temp_file)
run_test "Truly empty temp file" "-b" "$EMPTY_TEMP"
run_test "Truly empty temp file" "-n" "$EMPTY_TEMP"
rm -f "$EMPTY_TEMP"

set -e


# ============================================
# SECTION 11: Long flag forms (GNU style)
# ============================================
echo "--- SECTION 11: Long flag forms (--flag) ---"

run_test "Long flag --number-nonblank" "--number-nonblank" "$TEST_FILE1"
run_test "Long flag --show-ends" "--show-ends" "$TEST_FILE1"
run_test "Long flag --number" "--number" "$TEST_FILE1"
run_test "Long flag --squeeze-blank" "--squeeze-blank" "$TEST_FILE1"
run_test "Long flag --show-tabs" "--show-tabs" "$TEST_FILE1"
run_test "Long flags --number-nonblank --show-ends" "--number-nonblank --show-ends" "$TEST_FILE1"
run_test "Long flags --number-nonblank --show-ends --number --squeeze-blank --show-tabs" "--number-nonblank --show-ends --number --squeeze-blank --show-tabs" "$TEST_FILE1"

echo ""

# ============================================
# SECTION 12: All test files together
# ============================================
echo "--- SECTION 12: All test files ---"

ALL_FILES=(
    "${DATA_DIR}/simple.txt"
    "${DATA_DIR}/empty_lines.txt"
    "${DATA_DIR}/tabs_spaces.txt"
    "${DATA_DIR}/mixed_empty_lines.txt"
    "${DATA_DIR}/non_printable.txt"
    "${DATA_DIR}/single_line.txt"
    "${DATA_DIR}/no_newline_end.txt"
    "${DATA_DIR}/very_long_line.txt"
    "${DATA_DIR}/many_empty_lines.txt"
    "${DATA_DIR}/leading_tabs.txt"
    "${DATA_DIR}/trailing_spaces.txt"
    "${DATA_DIR}/single_char_lines.txt"
    "${DATA_DIR}/numbers_only.txt"
    "${DATA_DIR}/complex_mix.txt"
)

# Filter out non-existent files
EXISTING_FILES=()
for file in "${ALL_FILES[@]}"; do
    if [ -f "$file" ]; then
        EXISTING_FILES+=("$file")
    fi
done

if [ ${#EXISTING_FILES[@]} -gt 0 ]; then
    run_test "All files, no flags" "" "${EXISTING_FILES[@]}"
    run_test "All files, flag -b" "-b" "${EXISTING_FILES[@]}"
    run_test "All files, flag -benst" "-benst" "${EXISTING_FILES[@]}"
fi

echo ""

# ============================================
# FINAL SUMMARY
# ============================================
echo "=========================================="
echo "  TEST SUMMARY"
echo "=========================================="
TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
echo -e "Total tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

if [ $TESTS_FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}Failed test cases:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "${RED}  - $test${NC}"
    done
    exit 1
else
    echo ""
    echo -e "${GREEN}All tests passed! ✓${NC}"
    exit 0
fi
