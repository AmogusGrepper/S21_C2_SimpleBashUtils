#include "output.h"

#include <stdio.h>

#include "process.h"

void output_line_result(GrepState* state) {
  if (state->flags->l || state->flags->c) {
    return;
  }

  if (state->flags->n) {
    if (state->total_files > 1) {
      printf("%s:%ld:%s", state->file_ctx->filename, state->line_counter,
             state->line);
    } else {
      printf("%ld:%s", state->line_counter, state->line);
    }
  } else {
    if (state->total_files > 1) {
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
    if (state->total_files > 1) {
      printf("%s:%ld\n", state->file_ctx->filename,
             state->lines_matched_counter);
    } else {
      printf("%ld\n", state->lines_matched_counter);
    }
  }
}
