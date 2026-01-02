#include "utils.h"

bool is_line_empty(const char* line) {
  return line[0] == '\n' || line[0] == '\0';
}
