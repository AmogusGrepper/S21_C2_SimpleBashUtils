#ifndef CAT_PROCESS_H_
#define CAT_PROCESS_H_

#include <stdio.h>

#include "../common/file_reader.h"
#include "parse.h"

typedef struct {
  CatFlags* flags;

  size_t line_counter;
  size_t nonblank_counter;
  bool prev_empty;

  const char* line;
} CatState;

extern int run_cat(CatFlags* flags, char* const* filenames, int files_amount);

#endif
