#include "parse.h"
#include "process.h"

int main(int argc, char* const* argv) {
  CatFlags flags = parse_flags(&argc, argv);

  return run_cat(&flags, argv + optind, argc - optind);
}
