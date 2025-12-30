#include <stdio.h>

#include "command_parse.h"

int main(int argc, char* const* argv) {
  CatFlags flags = parse_flags(&argc, argv);

  putchar(flags.b);
  for (; optind < argc; ++optind) {
    printf("%s\n", argv[optind]);
  }

  return 0;
}
