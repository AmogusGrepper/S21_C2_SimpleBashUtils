#include "parse.h"

#include <getopt.h>

#include "../common/error.h"

const char* short_options = "benst";
const struct option long_options[] = {
    {"b", no_argument, 0, 'b'}, {"e", no_argument, 0, 'e'},
    {"n", no_argument, 0, 'n'}, {"s", no_argument, 0, 's'},
    {"t", no_argument, 0, 't'}, {0, 0, 0, 0},
};

CatFlags parse_flags(int* argc, char* const* argv) {
  CatFlags flags = {};
  int opt = 0;

  while ((opt = getopt_long(*argc, argv, short_options, long_options, 0)) !=
         -1) {
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
        print_usage_error("parse_flags", "Unknown flag");
        break;
    }
  }

  return flags;
};
