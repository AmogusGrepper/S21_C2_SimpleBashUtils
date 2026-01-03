#ifndef GREP_PARSE_H_
#define GREP_PARSE_H_

#include <getopt.h>
#include <stdbool.h>

typedef struct {
  bool e;
  bool i;
  bool v;
  bool c;
  bool l;
  bool n;
} GrepFlags;

extern const char* short_grep_options;
extern const struct option long_grep_options;

extern GrepFlags parse_grep_flags(int* argc, char* const* argv);

#endif
