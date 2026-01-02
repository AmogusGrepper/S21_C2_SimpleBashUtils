#ifndef FILE_UTILS_H_
#define FILE_UTILS_H_

#include <stdio.h>

typedef struct {
  FILE* fptr;
  const char* filename;
} FileContext;

extern int open_file(FileContext* ctx, const char* filename);
extern int read_line(FileContext* ctx, char** line, size_t* cap);
extern int close_file(FileContext* ctx);

#endif
