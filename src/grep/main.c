#include "parse.h"

#include <stdio.h>

int main(int argc, char* const* argv) {
  GrepFlags flags = parse_grep_flags(&argc, argv);

  printf("%i\n", flags.e);

  return 0;
}