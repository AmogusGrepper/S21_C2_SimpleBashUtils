#ifndef GREP_PROCESS_H_
#define GREP_PROCESS_H_

#include <stdbool.h>
#include <stddef.h>

#include "../common/file_reader.h"
#include "parse.h"

typedef struct {
  GrepFlags* flags;
  FileContext* file_ctx;

  const char* line;

  const char* pattern;

  size_t lines_matched_counter;
  size_t line_counter;

  size_t total_files;
  size_t total_matches;
  bool file_error_occurred;
} GrepState;

extern int run_grep(GrepFlags* flags, const char* pattern,
                    char* const* filenames, int files_amount);

#endif
