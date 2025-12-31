#include "process.h"

#include <stdlib.h>

#include "../common/error.h"
#include "../common/file_reader.h"

int run_cat(CatFlags* flags, char* const* filenames, int files_amount) {
  FileContext ctx = {};
  printf("%d\n\n", flags->b);

  for (int file_index = 0; file_index < files_amount; ++file_index) {
    const char* filename = filenames[file_index];

    if (open_file(&ctx, filename)) {
      print_file_error("run_cat", filename);
      return 1;
    }

    char* line = NULL;
    size_t capacity = 0;
    int read_line_result = 0;

    while ((read_line_result = read_line(&ctx, &line, &capacity)) > 0) {
      printf("%s", line);
    }
    if (read_line_result < 0) {
      print_file_error("run_cat", filename);
      return 2;
    }

    free(line);
    if (close_file(&ctx)) {
      print_file_error("run_cat", filename);
      return 3;
    }
  }

  return 0;
}
