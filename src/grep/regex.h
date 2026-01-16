#ifndef GREP_REGEX_H_
#define GREP_REGEX_H_

#include <regex.h>

#include "parse.h"

typedef struct {
  const char* pattern;
  regex_t* regex;
  int regex_flags;

  GrepFlags* grep_flags;

  const char** line;

} RegexState;

extern const char* combine_patterns(const char** patterns,
                                    const size_t patterns_amount);

extern int compile_regex(RegexState* regex_state);
extern bool execute_regex(RegexState* regex_state);
extern void free_regex(RegexState* regex_state);
extern int find_next_match(RegexState* regex_state, const char* line,
                           size_t start_pos, regmatch_t* match);

#endif
