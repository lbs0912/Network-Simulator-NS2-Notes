#ifndef JKL_STAT
#define JKL_STAT

#include "def.h"

void CalcLoss(dump_t *, unsigned, loss_t *, char *);
void CalcJitter(dump_t *, unsigned);
void PoBLoss(data_t *, double);
void OutJitter(dump_t *, unsigned, char *);
void CaldecodableFrame_GOP12(dump_t *, unsigned, char *);
void CaldecodableFrame_GOP9(dump_t *, unsigned, char *);
#endif
