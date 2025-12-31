#include "file_reader.h"

#include <stdio.h>

int open_file(FileContext* ctx, const char* filename) {
  ctx->fptr = fopen(filename, "r");
  if (!ctx->fptr) {
    return 1;
  }
  ctx->filename = filename;
  return 0;
}

int read_line(FileContext* ctx, char** line, size_t* cap) {
  ssize_t char_readed = getline(line, cap, ctx->fptr);
  if (char_readed == -1) {
    return 0;
  }
  ctx->line_counter++;
  return 1;
}

int close_file(FileContext* ctx) {
  int result = fclose(ctx->fptr);
  ctx->fptr = NULL;
  ctx->filename = NULL;
  return result;
}
