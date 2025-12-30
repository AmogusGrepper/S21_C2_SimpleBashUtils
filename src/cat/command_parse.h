#ifndef COMMAND_PARSE_CAT
#define COMMAND_PARSE_CAT

#include <getopt.h>
#include <stdbool.h>

typedef struct {
  bool b;
  bool e;
  bool n;
  bool s;
  bool t;
} CatFlags;

extern const char* short_options;
extern const struct option long_options[];

extern CatFlags parse_flags(int* argc, char* const* argv);

#endif
