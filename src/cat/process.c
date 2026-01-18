#include "process.h"

#include <stdio.h>
#include <stdlib.h>

#include "../common/error.h"
#include "../common/file_reader.h"
#include "../common/utils.h"
#include "parse.h"

static void print_formated_line(CatState* state);

int run_cat(CatFlags* flags, char* const* filenames, int files_amount) {
  FileContext ctx = {};
  CatState state = {flags, 0, 0, false, true, NULL};
  int result = 0;

  for (int file_index = 0; file_index < files_amount; ++file_index) {
    const char* filename = filenames[file_index];
    if (open_file(&ctx, filename)) {
      print_file_error("run_cat", filename);
      result = 1;
    } else {
      char* line = NULL;
      int read_line_result = 0;
      while ((read_line_result = read_line(&ctx, &line)) > 0 && result == 0) {
        state.line = line;
        print_formated_line(&state);
      }
      if (read_line_result < 0) {
        print_file_error("run_cat", filename);
        result = 2;
      }

      free(line);
      if (close_file(&ctx)) {
        print_file_error("run_cat", filename);
        result = 3;
      }
    }
  }
  return result;
}

static void print_formated_line(CatState* state) {
  bool is_empty = is_line_empty(state->line);

  // -s: squeeze consecutive empty lines (only at line start)
  if (state->flags->s && is_empty && state->line_started) {
    if (state->prev_empty) return;
    state->prev_empty = true;
  } else if (state->line_started) {
    state->prev_empty = false;
  }

  // Line numbering (only at line start)
  if (state->line_started) {
    if (state->flags->b && !is_empty) {
      state->nonblank_counter++;
      printf("%6zu\t", state->nonblank_counter);
    } else if (state->flags->n && !state->flags->b) {
      state->line_counter++;
      printf("%6zu\t", state->line_counter);
    }
  }

  // Print line content character by character
  for (int i = 0; state->line[i]; ++i) {
    unsigned char ch = state->line[i];
    if (ch == '\t') {
      if (state->flags->t) {
        printf("^I");
      } else {
        putchar('\t');
      }
    } else if (ch == '\n') {
      if (state->flags->e) putchar('$');
      putchar('\n');
      state->line_started = true;
    } else {
      putchar(ch);
      state->line_started = false;
    }
  }
}
