#include "file_reader.h"

#include <stdio.h>

int open_file(FileContext* ctx, const char* filename) {
  ctx->fptr = fopen(filename, "r");
  if (!ctx->fptr) {
    perror("open_file");
    return 1;
  }
  ctx->filename = filename;
  return 0;
}

/*
Return values:
  -1: Error occured while reading
   0: End of file reached
  >1: Succesfully readed
*/
int read_line(FileContext* ctx, char** line) {
  size_t cap = 0;
  ssize_t char_readed = getline(line, &cap, ctx->fptr);
  if (char_readed == -1) {
    if (feof(ctx->fptr)) {
      return 0;
    } else {
      perror("read_line");
      return -1;
    }
  }
  return 1;
}

int close_file(FileContext* ctx) {
  if (fclose(ctx->fptr)) {
    perror("close_file");
    return EOF;
  }
  ctx->fptr = NULL;
  ctx->filename = NULL;
  return 0;
}
