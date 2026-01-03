#include "process.h"

#include <stdio.h>
#include <stdlib.h>

#include "../common/error.h"
#include "../common/file_reader.h"
#include "../common/utils.h"
#include "parse.h"

static void print_formated_line(CatState* state);
static void print_control_char_form(const unsigned char ch);
static void print_visible_char_form(const unsigned char ch);

int run_cat(CatFlags* flags, char* const* filenames, int files_amount) {
  FileContext ctx = {};
  CatState state = {flags, 0, 0, false, NULL};

  for (int file_index = 0; file_index < files_amount; ++file_index) {
    const char* filename = filenames[file_index];

    if (open_file(&ctx, filename)) {
      print_file_error("run_cat", filename);
      return 1;
    }
    char* line = NULL;
    int read_line_result = 0;

    while ((read_line_result = read_line(&ctx, &line)) > 0) {
      state.line = line;
      print_formated_line(&state);
    }
    if (read_line_result < 0) {
      print_file_error("run_cat", filename);
      return 2;
    }

    // clear
    free(line);
    if (close_file(&ctx)) {
      print_file_error("run_cat", filename);
      return 3;
    }
    state.prev_empty = false;
  }

  return 0;
}

/* Formating line (state->line) according to flags (state->flags) and rules
below

s - squeeze blank

b - number non-blank
n - number

e - $ at end  , display non printing
t - tab as ^I, display non printing
*/
static void print_formated_line(CatState* state) {
  bool is_empty = is_line_empty(state->line);

  // -s
  if (state->flags->s && is_empty) {
    if (state->prev_empty) {
      return;
    }
    state->prev_empty = true;
  }
  if (!is_empty) {
    state->prev_empty = false;
  }

  // line counter
  state->line_counter++;
  if (!is_empty) {
    state->nonblank_counter++;
  }

  // -bn
  if (state->flags->b && !is_empty) {
    printf("%6zu\t", state->nonblank_counter);
  } else if (state->flags->n && !is_empty) {
    printf("%6zu\t", state->line_counter);
  }

  // -et
  bool flag_e = state->flags->e;
  bool flag_t = state->flags->t;
  for (int i = 0; state->line[i]; ++i) {
    char ch = state->line[i];
    if (flag_e && ch == '\n') {
      puts("$");
    } else if (flag_t && ch == '\t') {
      puts("^I");
    } else if (flag_e || flag_t) {
      print_visible_char_form(ch);
    } else {
      putchar(ch);
    }
  }
}

/* Printing chars between 0-127 */
static void print_control_char_form(const unsigned char ch) {
  if (ch < 32) {
    putchar('^');
    putchar(ch + 64);
  } else if (ch == 127) {
    putchar('^');
    putchar('?');
  }
}

/* Printing all chars in there visible form */
static void print_visible_char_form(const unsigned char ch) {
  if (ch >= 128) {
    putchar('M');
    putchar('-');
    const unsigned char low = ch - 128;
    print_control_char_form(low);
    if (low >= 32 && low < 127) {
      putchar(low);
    }
  } else {
    print_control_char_form(ch);
    if (ch >= 32 && ch < 127) {
      putchar(ch);
    }
  }
}
