#include "parse.h"

#include <bits/getopt_ext.h>
#include <getopt.h>

#include "../common/error.h"

const char* short_options = "eivcln";
const struct option long_options[] = {
    {"e", no_argument, 0, 'e'},
    {"i", no_argument, 0, 'i'},
    {"v", no_argument, 0, 'v'},
    {"c", no_argument, 0, 'c'},
    {"l", no_argument, 0, 'l'},
    {"n", no_argument, 0, 'n'},
    {0, 0, 0, 0},
};

GrepFlags parse_grep_flags(int* argc, char* const* argv) {
  GrepFlags flags = {};
  int opt = 0;

  while ((opt = getopt_long(*argc, argv, short_options, long_options, 0)) !=
         -1) {
    switch (opt) {
      case 'e':
        flags.e = true;
        break;

      case 'i':
        flags.i = true;
        break;

      case 'v':
        flags.v = true;
        break;

      case 'c':
        flags.c = true;
        break;

      case 'l':
        flags.l = true;
        break;

      case 'n':
        flags.n = true;
        break;

      default:
        print_usage_error("parse_grep_flags", "Unknown flag");
        break;
    }
  }

  return flags;
}
