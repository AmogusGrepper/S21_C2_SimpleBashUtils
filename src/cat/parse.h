#ifndef CAT_PARSE_H_
#define CAT_PARSE_H_

#include <getopt.h>
#include <stdbool.h>

typedef struct {
  bool b;
  bool e;
  bool n;
  bool s;
  bool t;
} CatFlags;

extern const char* short_cat_options;
extern const struct option long_cat_options[];

extern CatFlags parse_cat_flags(int* argc, char* const* argv);

#endif
