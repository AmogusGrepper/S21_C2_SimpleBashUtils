#ifndef GREP_PARSE_H_
#define GREP_PARSE_H_

#include <getopt.h>
#include <stdbool.h>
#include <stddef.h>

typedef struct {
  bool e;
  bool i;
  bool v;
  bool c;
  bool l;
  bool n;
} GrepFlags;

typedef struct {
  GrepFlags* flags;

  const char** patterns;
  size_t patterns_amount;
} GrepParseResult;

extern const char* short_grep_options;
extern const struct option long_grep_options[];

extern GrepParseResult parse_grep_flags(int* argc, char* const* argv,
                                        GrepFlags* flags);

#endif
