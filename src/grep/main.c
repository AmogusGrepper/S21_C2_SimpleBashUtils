#include <stdlib.h>

#include "parse.h"
#include "process.h"
#include "regex.h"

int main(int argc, char* const* argv) {
  GrepFlags flags = {};
  GrepParseResult parse_result = parse_grep_flags(&argc, argv, &flags);
  const char* pattern =
      combine_patterns(parse_result.patterns, parse_result.patterns_amount);
  int result = 0;

  // Free individual pattern strings
  for (size_t i = 0; i < parse_result.patterns_amount; ++i) {
    free((void*)parse_result.patterns[i]);
  }
  free(parse_result.patterns);

  if (pattern == NULL) {
    result = 1;
  } else {
    result =
        run_grep(parse_result.flags, pattern, argv + optind, argc - optind);
  }

  return result;
}
