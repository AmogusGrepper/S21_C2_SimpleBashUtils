#include <stdlib.h>

#include "parse.h"
#include "process.h"
#include "regex.h"

int main(int argc, char* const* argv) {
  GrepFlags flags = {};
  GrepParseResult parse_result = parse_grep_flags(&argc, argv, &flags);
  int result = 0;

  if (parse_result.parse_error) {
    result = 2;
  } else {
    const char* pattern =
        combine_patterns(parse_result.patterns, parse_result.patterns_amount);

    if (pattern == NULL) {
      result = 2;
    } else {
      result =
          run_grep(parse_result.flags, pattern, argv + optind, argc - optind);
    }
  }

  // Free individual pattern strings
  for (size_t i = 0; i < parse_result.patterns_amount; ++i) {
    free((void*)parse_result.patterns[i]);
  }
  free(parse_result.patterns);

  return result;
}
