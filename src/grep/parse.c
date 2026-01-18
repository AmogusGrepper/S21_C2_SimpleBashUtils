#include "parse.h"

#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../common/error.h"

const char* short_grep_options = "e:ivclnhsf:o";
const struct option long_grep_options[] = {
    {"regexp", required_argument, 0, 'e'},
    {"ignore-case", no_argument, 0, 'i'},
    {"invert-match", no_argument, 0, 'v'},
    {"count", no_argument, 0, 'c'},
    {"files-with-matches", no_argument, 0, 'l'},
    {"line-number", no_argument, 0, 'n'},
    {"no-filename", no_argument, 0, 'h'},
    {"no-messages", no_argument, 0, 's'},
    {"file", required_argument, 0, 'f'},
    {"only-matching", no_argument, 0, 'o'},
    {0, 0, 0, 0},
};

static bool add_pattern_to_result(GrepParseResult* result,
                                  const char* pattern) {
  result->patterns =
      realloc(result->patterns, sizeof(char*) * (result->patterns_amount + 1));
  if (result->patterns == NULL) {
    print_usage_error("add_pattern_to_result",
                      "Error during memory allocation for result.patterns");
    return false;
  }
  result->patterns[result->patterns_amount] = malloc(strlen(pattern) + 1);
  if (result->patterns[result->patterns_amount] == NULL) {
    print_usage_error("add_pattern_to_result",
                      "Error during memory allocation for pattern");
    return false;
  }
  strcpy((char*)result->patterns[result->patterns_amount], pattern);
  result->patterns_amount++;
  return true;
}

static void parse_pattern_from_file(GrepParseResult* result,
                                    const char* filename) {
  FILE* pattern_file = fopen(filename, "r");
  bool file_opened = (pattern_file != NULL);

  if (file_opened) {
    char* line = NULL;
    size_t cap = 0;
    ssize_t read;
    bool read_success = true;

    while ((read = getline(&line, &cap, pattern_file)) != -1 && read_success) {
      if (read > 0 && line[read - 1] == '\n') {
        line[read - 1] = '\0';
        read--;
      }

      read_success = add_pattern_to_result(result, line);
    }
    free(line);
    fclose(pattern_file);
  } else {
    print_file_error("parse_pattern_from_file", filename);
  }
}

static void parse_default_pattern(GrepParseResult* result, const int* argc,
                                  char* const* argv) {
  bool pattern_available = (optind < *argc);

  if (pattern_available) {
    result->patterns = malloc(sizeof(char*));
    if (result->patterns == NULL) {
      print_usage_error("parse_default_pattern",
                        "Error during memory allocation for result.patterns");
    } else {
      result->patterns[0] = malloc(strlen(argv[optind]) + 1);
      if (result->patterns[0] == NULL) {
        print_usage_error("parse_default_pattern",
                          "Error during memory allocation for pattern");
      } else {
        strcpy((char*)result->patterns[0], argv[optind++]);
        result->patterns_amount = 1;
      }
    }
  } else {
    print_usage_error("parse_default_pattern", "Missing PATTERN");
  }
}

GrepParseResult parse_grep_flags(int* argc, char* const* argv,
                                 GrepFlags* flags) {
  GrepParseResult result = {
      .flags = flags,
      .patterns = NULL,
      .patterns_amount = 0,
      .parse_error = false,
  };

  int opt = 0;

  while ((opt = getopt_long(*argc, argv, short_grep_options, long_grep_options,
                            0)) != -1) {
    switch (opt) {
      case 'e':
        result.flags->e = true;
        add_pattern_to_result(&result, optarg);
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

      case 'h':
        result.flags->h = true;
        break;

      case 's':
        result.flags->s = true;
        break;

      case 'f':
        result.flags->f = true;
        parse_pattern_from_file(&result, optarg);
        break;

      case 'o':
        result.flags->o = true;
        break;

      default:
        print_usage_error("parse_grep_flags", "Unknown flag");
        break;
    }
  }

  if (result.patterns_amount == 0) {
    parse_default_pattern(&result, argc, argv);
  }

  return result;
}
