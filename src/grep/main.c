#include "parse.h"
#include "process.h"

int main(int argc, char* const* argv) {
  GrepParseResult parse_result = parse_grep_flags(&argc, argv);

  return run_grep(parse_result.flags, parse_result.patterns,
                  parse_result.patterns_amount, argv + optind, argc - optind);
}
