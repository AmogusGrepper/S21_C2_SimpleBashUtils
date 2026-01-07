#include <stdlib.h>

#include "parse.h"
#include "process.h"
#include "regex.h"

int main(int argc, char* const* argv) {
  GrepFlags flags = {};
  GrepParseResult parse_result = parse_grep_flags(&argc, argv, &flags);
  const char* pattern =
      combine_patterns(parse_result.patterns, parse_result.patterns_amount);
  free(parse_result.patterns);

  if (pattern == NULL) {
    return 1;
  }

  return run_grep(parse_result.flags, pattern, argv + optind, argc - optind);
}
