
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "read.h"
#include "stat.h"

static data_t D;
static loss_t P, F;

int main(int cn, char **cl)
{
  double PoB = 0;
  char id[42] = {0};
  int choice;

  if (cn < 6) {
    puts("usage: et <sd> <rd> <st> <id> <GOP> [PoB]");
    puts("  <sd> tcpdump sender");
    puts("  <rd> tcpdump receiver");
    puts("  <st> tracefile sender");
    puts("  <id> id of output file");
	puts("  <GOP> 1: GOP9, 2: GOP12");
    puts(" [PoB] optional Play-out buffer size [sec]");
    return 0;
  }

  strncpy(id, cl[4], sizeof id - 1);
  choice=atoi(cl[5]);

  if (cn == 7) {
	PoB=strtod(cl[6], NULL);
	printf("Play-out buffer size:%f seconds\n", PoB);
  }

  if (strcmp(cl[1], cl[2]) == 0) {
	printf("<sd>:%s and <rd>:%s are the same\n", cl[1], cl[2]);
	return 0;
  }

  if (!ReadDump(cl, &D, FRAME, 0, choice)) return EXIT_FAILURE;

  if(cn == 7) 
	  printf("Before processing Play-out Buffer\n");
 
  CalcLoss(D.P, D.nP, &P, 0);
  CalcLoss(D.F, D.nF, &F, id);

  CalcJitter(D.P, D.nP);
  CalcJitter(D.F, D.nF);

  if (PoB) PoBLoss(&D, PoB);

  if(cn == 7) {
	printf("\nAfter processing Play-out Buffer\n");
	CalcLoss(D.P, D.nP, &P, 0);
	CalcLoss(D.F, D.nF, &F, id);
  }

  OutJitter(D.P, D.nP, 0);
  OutJitter(D.F, D.nF, id);

  if (choice==1) {
	CaldecodableFrame_GOP9(D.F, D.nF, id);
  } else if (choice==2) {
	CaldecodableFrame_GOP12(D.F, D.nF, id);
  } else {
	printf("wrong choice for GOP pattern\n");
  }

  free(D.P);
  free(D.F);

  return 0;
}
