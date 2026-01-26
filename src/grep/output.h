#ifndef GREP_OUTPUT_H_
#define GREP_OUTPUT_H_

#include "parse.h"
#include "process.h"

extern void output_line_result(GrepState* state);
extern void output_file_result(GrepState* state);
extern void output_match_only(GrepState* state, const char* match_start,
                              size_t match_length);

#endif
