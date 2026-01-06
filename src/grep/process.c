#include "process.h"

#include <stdlib.h>

#include "../common/error.h"
#include "../common/file_reader.h"
#include "../common/utils.h"

int run_grep(GrepFlags* flags, const char** patterns, size_t patterns_amount,
             char* const* filenames, int files_amount) {
  GrepState state = {.flags = flags,
                     .file_ctx = {},
                     .patterns_amount = patterns_amount,
                     .patterns = patterns,
                     .files_matched_counter = 0,
                     .lines_matched_counter = 0,
                     .total_files = 0,
                     .total_lines = 0};

  for (int file_index = 0; file_index < files_amount; ++file_index) {
    const char* filename = filenames[file_index];

    if (open_file(state.file_ctx, filename)) {
      print_file_error("run_grep", filename);
      return 1;
    }
    char* line = NULL;
    int read_line_result = 0;

    while ((read_line_result = read_line(state.file_ctx, &line)) > 0) {
      state.line = line;
      // todo format line
    }
    if (read_line_result < 0) {
      print_file_error("run_grep", filename);
      return 2;
    }

    // clear
    free(line);
    if (close_file(state.file_ctx)) {
      
    }
  }

  return 0;
}
