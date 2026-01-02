#ifndef FILE_UTILS_H_
#define FILE_UTILS_H_

#include <stdio.h>

typedef struct {
  FILE* fptr;
  const char* filename;
} FileContext;

/**
 * @brief Read line from FILE* ctx->fptr and store to line
 *
 * @param ctx File context
 * @param filename Name of file to open
 *
 * @retval 1 Open error
 * @retval 0 Success
 */
extern int open_file(FileContext* ctx, const char* filename);

/**
 * @brief Read line from FILE pointer and store to line
 *
 * @param[in] ctx File context
 * @param[out] line Pointer to output line
 *
 * @retval -1 Error occured while reading
 * @retval  0 End of file reached
 * @retval  1 Succesfully readed
 */
extern int read_line(FileContext* ctx, char** line);

/**
 * @brief Close file and clear context
 *
 * @param ctx File context
 *
 * @retval EOF Close error
 * @retval   0 Success
 */
extern int close_file(FileContext* ctx);

#endif
