#include "output.h"

#include <stdio.h>
#include <string.h>

#include "process.h"

void output_line_result(GrepState* state) {
  if (state->flags->l || state->flags->c) {
    return;
  }

  if (state->flags->o) {
    return;
  }

  bool print_filename = (state->total_files > 1) && !state->flags->h;

  if (state->flags->n) {
    if (print_filename) {
      printf("%s:%zu:%s", state->file_ctx->filename, state->line_counter,
             state->line);
    } else {
      printf("%zu:%s", state->line_counter, state->line);
    }
  } else {
    if (print_filename) {
      printf("%s:%s", state->file_ctx->filename, state->line);
    } else {
      printf("%s", state->line);
    }
  }
}

void output_file_result(GrepState* state) {
  if (state->flags->l) {
    if (state->lines_matched_counter > 0) {
      printf("%s\n", state->file_ctx->filename);
    }
  } else if (state->flags->c) {
    bool print_filename = (state->total_files > 1) && !state->flags->h;
    if (print_filename) {
      printf("%s:%zu\n", state->file_ctx->filename,
             state->lines_matched_counter);
    } else {
      printf("%zu\n", state->lines_matched_counter);
    }
  }
}

void output_match_only(GrepState* state, const char* match_start,
                       size_t match_length) {
  bool print_filename = (state->total_files > 1) && !state->flags->h;

  if (state->flags->n) {
    if (print_filename) {
      printf("%s:%zu:", state->file_ctx->filename, state->line_counter);
    } else {
      printf("%zu:", state->line_counter);
    }
  } else {
    if (print_filename) {
      printf("%s:", state->file_ctx->filename);
    }
  }

  // printing matching part
  for (size_t i = 0; i < match_length; ++i) {
    printf("%c", match_start[i]);
  }
  printf("\n");
}
