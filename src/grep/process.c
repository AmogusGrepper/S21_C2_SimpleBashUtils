#include "process.h"

#include <regex.h>
#include <stdlib.h>
#include <string.h>

#include "../common/error.h"
#include "../common/file_reader.h"
#include "output.h"
#include "regex.h"

static void process_match_only(GrepState* state, RegexState* regex_state,
                               const char* line) {
  size_t search_pos = 0;
  regmatch_t match;
  while (find_next_match(regex_state, line, search_pos, &match) == 0) {
    size_t match_start = match.rm_so;
    size_t match_end = match.rm_eo;
    size_t match_length = match_end - match_start;

    if (match_length > 0) {
      output_match_only(state, line + match_start, match_length);
    }

    if (match_end > match_start) {
      search_pos = match_end;
    } else {
      search_pos++;
    }

    if (match_length == 0) {
      break;
    }
  }
}

static void strip_newline(char* line, size_t* newline_pos) {
  size_t len = strlen(line);
  *newline_pos = 0;
  if (len > 0 && line[len - 1] == '\n') {
    *newline_pos = len - 1;
    line[len - 1] = '\0';
  }
}

static void restore_newline(char* line, size_t newline_pos) {
  if (newline_pos > 0) {
    line[newline_pos] = '\n';
  }
}

static void process_file_lines(GrepState* state, RegexState* regex_state,
                               const char* filename) {
  char* line = NULL;
  int read_line_result = 0;
  bool read_success = true;

  while ((read_line_result = read_line(state->file_ctx, &line)) > 0) {
    size_t newline_pos = 0;
    strip_newline(line, &newline_pos);

    state->line = line;
    regex_state->line = &state->line;

    int exec_result = execute_regex(regex_state);
    if (exec_result) {
      state->lines_matched_counter++;
      state->total_matches++;

      restore_newline(line, newline_pos);

      if (state->flags->o && !state->flags->v && !state->flags->c &&
          !state->flags->l) {
        process_match_only(state, regex_state, line);
      } else {
        output_line_result(state);
      }
    } else {
      restore_newline(line, newline_pos);
    }
    state->line_counter++;
  }

  if (read_line_result < 0) {
    if (!state->flags->s) {
      print_file_error("process_file_lines", filename);
    }
    state->file_error_occurred = true;
    read_success = false;
  }

  if (read_success) {
    output_file_result(state);
  }

  free(line);
}

static void process_single_file(GrepState* state, RegexState* regex_state,
                                const char* filename) {
  state->line = NULL;
  regex_state->line = NULL;
  state->line_counter = 1;
  state->lines_matched_counter = 0;

  bool file_opened = (open_file(state->file_ctx, filename) == 0);

  if (file_opened) {
    process_file_lines(state, regex_state, filename);

    if (close_file(state->file_ctx)) {
      if (!state->flags->s) {
        print_file_error("process_single_file", filename);
      }
      state->file_error_occurred = true;
    }
  } else {
    if (!state->flags->s) {
      print_file_error("process_single_file", filename);
    }
    state->file_error_occurred = true;
  }
}

static int determine_exit_code(const GrepState* state, bool regex_error) {
  int exit_code = 0;
  if (regex_error) {
    exit_code = 2;
  } else if (state->file_error_occurred) {
    exit_code = 2;
  } else if (state->total_matches == 0) {
    exit_code = 1;
  }
  return exit_code;
}

int run_grep(GrepFlags* flags, const char* pattern, char* const* filenames,
             int files_amount) {
  FileContext file_context = {};
  GrepState state = {
      .flags = flags,
      .file_ctx = &file_context,
      .pattern = pattern,
      .lines_matched_counter = 0,
      .line_counter = 1,
      .total_files = files_amount,
      .total_matches = 0,
      .file_error_occurred = false,
  };

  regex_t regex = {};
  RegexState regex_state = {
      .pattern = pattern,
      .regex = &regex,
      .regex_flags = 0,
      .grep_flags = flags,
  };
  int result = compile_regex(&regex_state);
  bool regex_error = (result != 0);

  if (result) {
    print_usage_error("run_grep", "Error in compile_regex");

  } else {
    for (int file_index = 0; file_index < files_amount; ++file_index) {
      const char* filename = filenames[file_index];
      process_single_file(&state, &regex_state, filename);
    }
  }

  free_regex(&regex_state);

  return determine_exit_code(&state, regex_error);
}
