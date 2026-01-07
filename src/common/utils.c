#include "utils.h"

#include <string.h>

bool is_line_empty(const char* line) {
  return line[0] == '\n' || line[0] == '\0';
}

extern size_t count_lines_length(const char** lines,
                                 const size_t lines_amount) {
  size_t length = 0;

  for (size_t i = 0; i < lines_amount; ++i) {
    length += strlen(lines[i]);
  }

  return length;
}
