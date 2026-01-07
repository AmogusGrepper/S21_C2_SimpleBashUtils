#include "parse.h"

#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>

#include "../common/error.h"

const char* short_grep_options = "e:ivcln";
const struct option long_grep_options[] = {
    {"regexp", required_argument, 0, 'e'},
    {"ignore-case", no_argument, 0, 'i'},
    {"invert-match", no_argument, 0, 'v'},
    {"count", no_argument, 0, 'c'},
    {"files-with-matches", no_argument, 0, 'l'},
    {"line-number", no_argument, 0, 'n'},
    {0, 0, 0, 0},
};

GrepParseResult parse_grep_flags(int* argc, char* const* argv,
                                 GrepFlags* flags) {
  GrepParseResult result = {
      .flags = flags,
      .patterns = NULL,
      .patterns_amount = 0,
  };

  int opt = 0;

  while ((opt = getopt_long(*argc, argv, short_grep_options, long_grep_options,
                            0)) != -1) {
    switch (opt) {
      case 'e':
        result.flags->e = true;
        result.patterns = realloc(result.patterns,
                                  sizeof(char*) * (result.patterns_amount + 1));
        if (result.patterns == NULL) {
          print_usage_error(
              "parse_grep_flags",
              "Error during memory allocation for result.patterns");
        }
        result.patterns[result.patterns_amount++] = optarg;
        break;

      case 'i':
        result.flags->i = true;
        break;

      case 'v':
        result.flags->v = true;
        break;

      case 'c':
        result.flags->c = true;
        break;

      case 'l':
        result.flags->l = true;
        break;

      case 'n':
        result.flags->n = true;
        break;

      default:
        print_usage_error("parse_grep_flags", "Unknown flag");
        break;
    }
  }

  if (result.patterns_amount == 0) {
    if (optind >= *argc) {
      print_usage_error("parse_grep_flags", "Missing PATTERN");
    }
    result.patterns = malloc(sizeof(char*));
    if (result.patterns == NULL) {
      print_usage_error("parse_grep_flags",
                        "Error during memory allocation for result.patterns");
    }
    result.patterns[0] = argv[optind++];
    result.patterns_amount = 1;
  }

  return result;
}
