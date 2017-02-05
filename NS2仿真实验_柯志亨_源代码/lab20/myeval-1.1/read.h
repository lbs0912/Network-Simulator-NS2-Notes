#ifndef JKL_READ
#define JKL_READ

#include "def.h"

#ifdef __cplusplus
extern "C" {
#endif
  int ReadIni(char *, param_t *);
#ifdef __cplusplus
}
#endif

int ReadDump(char **, data_t *, MODE, int, int);
#endif
