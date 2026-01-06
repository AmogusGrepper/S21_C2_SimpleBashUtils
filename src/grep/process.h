#ifndef GREP_PROCESS_H_
#define GREP_PROCESS_H_

#include <stddef.h>

#include "../common/file_reader.h"
#include "parse.h"

typedef struct {
  GrepFlags* flags;
  FileContext* file_ctx;

  const char* line;

  const char** patterns;
  const size_t patterns_amount;

  size_t files_matched_counter;
  size_t lines_matched_counter;
  size_t total_files;
  size_t total_lines;
} GrepState;

extern int run_grep(GrepFlags* flags, const char** patterns,
                    size_t patterns_amount, char* const* filenames,
                    int files_amount);

#endif
