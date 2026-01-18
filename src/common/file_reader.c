#include "file_reader.h"

#include <stdio.h>

int open_file(FileContext* ctx, const char* filename) {
  ctx->fptr = fopen(filename, "r");
  int result = 0;
  if (!ctx->fptr) {
    result = 1;
  } else {
    ctx->filename = filename;
    ctx->line_capacity = 0;
  }
  return result;
}

int read_line(FileContext* ctx, char** line) {
  ssize_t char_readed = getline(line, &ctx->line_capacity, ctx->fptr);
  int result = 1;
  if (char_readed == -1) {
    if (feof(ctx->fptr)) {
      result = 0;
    } else {
      result = -1;
    }
  }
  return result;
}

int close_file(FileContext* ctx) {
  int result = 0;
  if (fclose(ctx->fptr)) {
    result = EOF;
  } else {
    ctx->fptr = NULL;
    ctx->filename = NULL;
    ctx->line_capacity = 0;
  }
  return result;
}
