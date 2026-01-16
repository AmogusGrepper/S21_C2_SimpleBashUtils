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
      case 'e': {
        result.flags->e = true;
        result.patterns = realloc(result.patterns,
                                  sizeof(char*) * (result.patterns_amount + 1));
        if (result.patterns == NULL) {
          print_usage_error(
              "parse_grep_flags",
              "Error during memory allocation for result.patterns");
          break;
        }
        result.patterns[result.patterns_amount] = malloc(strlen(optarg) + 1);
        if (result.patterns[result.patterns_amount] == NULL) {
          print_usage_error("parse_grep_flags",
                            "Error during memory allocation for pattern");
          break;
        }
        strcpy((char*)result.patterns[result.patterns_amount], optarg);
        result.patterns_amount++;
        break;
      }

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

      case 'f': {
        result.flags->f = true;
        FILE* pattern_file = fopen(optarg, "r");
        if (pattern_file == NULL) {
          print_file_error("parse_grep_flags", optarg);
          break;
        }

        char* line = NULL;
        size_t cap = 0;
        ssize_t read;
        while ((read = getline(&line, &cap, pattern_file)) != -1) {
          if (read > 0 && line[read - 1] == '\n') {
            line[read - 1] = '\0';
            read--;
          }

          result.patterns = realloc(
              result.patterns, sizeof(char*) * (result.patterns_amount + 1));
          if (result.patterns == NULL) {
            print_usage_error(
                "parse_grep_flags",
                "Error during memory allocation for result.patterns");
            free(line);
            fclose(pattern_file);
            break;
          }
          result.patterns[result.patterns_amount] = malloc(strlen(line) + 1);
          if (result.patterns[result.patterns_amount] == NULL) {
            print_usage_error("parse_grep_flags",
                              "Error during memory allocation for pattern");
            free(line);
            fclose(pattern_file);
            break;
          }
          strcpy((char*)result.patterns[result.patterns_amount], line);
          result.patterns_amount++;
        }
        free(line);
        fclose(pattern_file);
        break;
      }

      case 'o':
        result.flags->o = true;
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
    result.patterns[0] = malloc(strlen(argv[optind]) + 1);
    if (result.patterns[0] == NULL) {
      print_usage_error("parse_grep_flags",
                        "Error during memory allocation for pattern");
    } else {
      strcpy((char*)result.patterns[0], argv[optind++]);
      result.patterns_amount = 1;
    }
  }

  return result;
}
