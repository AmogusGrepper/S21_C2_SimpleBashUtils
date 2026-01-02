#!/usr/bin/env bash

set -e

command_test="$1"
test_file="$2"
pattern="${3:-pattern}"

if [[ "$command_test" == "s21_cat" ]]; then
  make s21_cat
  printf '\n====TEST====\n\n'
  ./s21_cat -benst "$test_file" | diff -u - <(cat -benst "$test_file")
elif [[ "$command_test" == "s21_grep" ]]; then
  make s21_grep
  printf '\n====TEST====\n\n'
  ./s21_grep -ivn "$pattern" "$test_file" | diff -u - <(grep -ivn "$pattern" "$test_file")
else
  echo "Unknown command: $command_test"
  exit 1
fi

