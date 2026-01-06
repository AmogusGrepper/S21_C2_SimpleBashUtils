#ifndef GREP_DEBUG_H_
#define GREP_DEBUG_H_

#include <stdio.h>

#include "parse.h"
#include "process.h"

static void print_grep_flags(GrepFlags* flags) {
  if (!flags) {
    printf("flags: (null)\n");
    return;
  }

  puts("Flags:");
  printf("flags: e=%d i=%d v=%d c=%d l=%d n=%d\n", flags->e, flags->i, flags->v,
         flags->c, flags->l, flags->n);
}

static void print_grep_patterns(const char** patterns,
                           const size_t patterns_amount) {
  if (!patterns) {
    printf("patterns: (null)\n");
    return;
  }

  puts("Patterns:");
  for (size_t i = 0; i < patterns_amount; ++i) {
    printf("  [%zu]: %s\n", i, patterns[i] ? patterns[i] : "(null)");
  }
}

static void print_grep_state(GrepState* state) {
  if (!state) {
    printf("state: (null)\n");
    return;
  }

  print_grep_flags(state->flags);
  print_grep_patterns(state->patterns, state->patterns_amount);

  printf("line: %s", state->line ? state->line : "(null)");
  printf("patterns_amount: %zu\n", state->patterns_amount);
  printf("files_matched_counter: %zu\n", state->files_matched_counter);
  printf("lines_matched_counter: %zu\n", state->lines_matched_counter);
  printf("total_files: %zu\n", state->total_files);
  printf("total_lines: %zu\n", state->total_lines);
  putchar('\n');
}

#endif
