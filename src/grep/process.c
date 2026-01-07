#include "process.h"

#include <stdlib.h>

#include "../common/error.h"
#include "../common/file_reader.h"
#include "regex.h"

int run_grep(GrepFlags* flags, const char* pattern, char* const* filenames,
             int files_amount) {
  FileContext file_context = {};
  GrepState state = {
      .flags = flags,
      .file_ctx = &file_context,
      .pattern = pattern,
      .files_matched_counter = 0,
      .lines_matched_counter = 0,
      .total_files = 0,
      .total_lines = 0,
  };

  regex_t regex = {};
  RegexState regex_state = {
      .pattern = pattern,
      .regex = &regex,
      .regex_flags = 0,
      .grep_flags = flags,
  };
  int result = compile_regex(&regex_state);
  if (result) {
    print_usage_error("run_grep", "Error in compile_regex");
    return 1;
  }

  for (int file_index = 0; file_index < files_amount; ++file_index) {
    // open file
    const char* filename = filenames[file_index];
    if (open_file(state.file_ctx, filename)) {
      print_file_error("run_grep", filename);
      return 2;
    }

    // read line
    char* line = NULL;
    int read_line_result = 0;
    while ((read_line_result = read_line(state.file_ctx, &line)) > 0) {
      state.line = line;
      regex_state.line = &state.line;

      if (execute_regex(&regex_state)) {
        puts(line);
      }
      // print_grep_state(&state);
    }
    if (read_line_result < 0) {
      print_file_error("run_grep", filename);
      return 3;
    }

    // clear
    free(line);
    state.line = NULL;
    regex_state.line = NULL;
    if (close_file(state.file_ctx)) {
      print_file_error("run_grep", filename);
      return 4;
    }
  }

  free_regex(&regex_state);

  return 0;
}
