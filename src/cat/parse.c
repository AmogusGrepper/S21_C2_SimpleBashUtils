#include "parse.h"

#include <getopt.h>

#include "../common/error.h"

const char* short_cat_options = "benst";
const struct option long_cat_options[] = {
    {"number-nonblank", no_argument, 0, 'b'},
    {"show-ends", no_argument, 0, 'e'},
    {"number", no_argument, 0, 'n'},
    {"squeeze-blank", no_argument, 0, 's'},
    {"show-tabs", no_argument, 0, 't'},
    {0, 0, 0, 0},
};

CatFlags parse_cat_flags(int* argc, char* const* argv) {
  CatFlags flags = {};
  int opt = 0;

  while ((opt = getopt_long(*argc, argv, short_cat_options, long_cat_options,
                            0)) != -1) {
    switch (opt) {
      case 'b':
        flags.b = true;
        break;

      case 'e':
        flags.e = true;
        break;

      case 'n':
        flags.n = true;
        break;

      case 's':
        flags.s = true;
        break;

      case 't':
        flags.t = true;
        break;

      default:
        print_usage_error("parse_cat_flags", "Unknown flag");
        break;
    }
  }

  return flags;
}
