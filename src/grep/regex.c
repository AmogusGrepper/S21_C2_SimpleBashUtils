#include "regex.h"

#include <regex.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../common/error.h"
#include "../common/utils.h"

const char* combine_patterns(const char** patterns,
                             const size_t patterns_amount) {
  size_t final_pattern_length =
      count_lines_length(patterns, patterns_amount) + patterns_amount * 3 + 1;
  char* final_pattern = (char*)malloc(sizeof(char) * final_pattern_length);
  (final_pattern)[0] = '\0';

  for (size_t i = 0; i < patterns_amount; ++i) {
    strcat(final_pattern, "(");
    strcat(final_pattern, patterns[i]);
    strcat(final_pattern, ")");
    if (i < patterns_amount - 1) {
      strcat(final_pattern, "|");
    }
  }

  return final_pattern;
}

int compile_regex(RegexState* regex_state) {
  regex_state->regex_flags = REG_EXTENDED;
  if (regex_state->grep_flags->i) {
    regex_state->regex_flags |= REG_ICASE;
  }

  int result = regcomp(regex_state->regex, regex_state->pattern,
                       regex_state->regex_flags);
  if (result != 0) {
    print_usage_error("compile_regex", "Error compiling regex");
    return 1;
  }

  return 0;
}

bool execute_regex(RegexState* regex_state) {
  int match = regexec(regex_state->regex, *(regex_state->line), 0, NULL, 0);
  bool matched = (match == 0);
  if (regex_state->grep_flags->v) {
    matched = !matched;
  }

  return matched;
}

void free_regex(RegexState* regex_state) {
  free((void*)regex_state->pattern);
  regfree(regex_state->regex);
}
