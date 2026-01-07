#ifndef UTILS_H_
#define UTILS_H_

#include <stdbool.h>
#include <stddef.h>

extern bool is_line_empty(const char* line);
extern size_t count_lines_length(const char** lines, const size_t lines_amount);

#endif
