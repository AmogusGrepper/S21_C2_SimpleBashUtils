#ifndef ERROR_H_
#define ERROR_H_

#include <errno.h>
#include <stdio.h>
#include <string.h>

static inline void print_file_error(const char* func, const char* filename) {
  fprintf(stderr, "%s: %s: ", func, filename);
  perror(NULL);
}

static inline void print_usage_error(const char* func, const char* msg) {
  fprintf(stderr, "%s: %s\n", func, msg);
}

#endif
