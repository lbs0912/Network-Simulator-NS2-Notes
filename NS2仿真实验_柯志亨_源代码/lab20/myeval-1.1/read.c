
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "def.h"
#include "read.h"
#include "misc.h"

static const char FMT_T[] = "%*d %c %d%d%*[^\n]\n";

int ReadDump(char *fl[], data_t *D, MODE mode, int off, int choice)
{
  static dump_t null;
  FILE *f = 0;
  double t = 0, tmax, time;
  unsigned long i, ti, line, id = 0;
  char buf[0x1000], *p, *e, j, c, tmp1[10], tmp2[10], tmp3[10];
  int l=0, h, m, lost, seq;
  size_t num = 0;
  void *tmp;

  /* tcpdump sender */
  if ((f = fopen(fl[1], "r")) == 0) {
    fprintf(stderr, "error opening %s\n", fl[1]);
    return 0;
  }

  line = 0;
  while (c = 0, line++, !feof(f) && !ferror(f)) {
    if (!fgets(buf, sizeof buf, f) || feof(f) || ferror(f)) break;
    if (*buf == '\n') continue;

    if (!(t = strtod(buf, &e)) && e == buf) { c = 1; goto e1; }
    if (!(p = skips(buf, " id ", 1))) {
      if (!(p = skips(buf, "frag ", 1))) { c = 1; goto e1; }
    }
    if (!(id = strtoul(p, &e, 10)) && e == p) { c = 1; goto e1; }
    if (!(p = skips(buf, " udp ", 1)))
      if (!(p = skips(buf, "UDP, length:", 1)))
        if (!(p = skips(buf, "UDP, length", 1))) { c = 1; goto e1; }
    if (!(l = strtoul(p, &e, 10)) && e == p) c = 1;

e1: if (c) {
      fprintf(stderr, "malformed input (%s, %lu)\n", fl[1], line);
      continue;
    }

    if (++D->nP > num) {
      num += 16384;
      if ((tmp = realloc(D->P, num * sizeof *D->P)) == 0) {
        fprintf(stderr, "realloc error\n");
        return 0;
      }
      D->P = tmp;
    }

    D->P[D->nP-1] = null;
    D->P[D->nP-1].id = id;
    D->P[D->nP-1].t1 = t; /* t1: send time */
    D->P[D->nP-1].size = l - off; /* l: packet size */
    D->P[D->nP-1].lost = 1;
    D->P[D->nP-1].type = ' ';
  }
  fclose(f);

  /* tcpdump receiver */
  if ((f = fopen(fl[2], "r")) == 0) {
    fprintf(stderr, "error opening %s\n", fl[2]);
    return 0;
  }

  line = m = 0;
  while (lost=0, c=0, line++, !feof(f) && !ferror(f)) {
    if (!fgets(buf, sizeof buf, f) || feof(f) || ferror(f)) break;
    if (*buf == '\n') continue;

    if (!(t = strtod(buf, &e)) && e == buf) { c = 1; goto e2; }
    if (!(p = skips(buf, " id ", 1))) { c = 1; goto e2; }
    if (!(id = strtoul(p, &e, 10)) && e == p) { c = 1; goto e2; }

e2: if (c) {
      fprintf(stderr, "malformed input (%s, %lu)\n", fl[2], line);
      continue;
    }

    if (p = skips(buf, " lost ", 1)) lost = strtoul(p, 0, 10);

    for (i=m; i<D->nP; i++)
      if (id == D->P[i].id) {
        D->P[i].t2 = t; /* t2: received time */
        D->P[i].lost = lost; /* not lost:0, lost: other value */
        if (i > 100) m = i - 100;
        break;
      }
  }
  fclose(f);

  /* tracefile sender */
  if ((f = fopen(fl[3], "r")) == 0) {
    fprintf(stderr, "error opening %s\n", fl[3]);
    return 0;
  }

  i = 0;
  line = num = 0;
  while (c = 0, line++, !feof(f) && !ferror(f)) {
	  if(choice==1){
		  if (5 != fscanf(f, "%d %c %d %d %f\n", &seq, &c, &m, &l, &time)) { 
			if (!feof(f)) {
				fprintf(stderr, "malformed input (%s, %lu)\n", fl[3], line);
				continue;
			} else break;
		} 
	  }
	  
	  if(choice==2){
		if (4 != fscanf(f, "%d %c %d %d\n", &seq, &c, &m, &l)) {
			if (!feof(f)) {
				fprintf(stderr, "malformed input (%s, %lu)\n", fl[3], line);
				continue;
			} else break;
		} 
	  }

	/* if (i >= D->nP) {  
	  printf("i:%ld, D->nP:%ld\n", i, D->nP);
      fprintf(stderr, "%s incomplete\n", fl[1]);
      return 0;
    } */

    ti = i;
    tmax = D->P[i].lost ? 0 : D->P[i].t2;
    for (j=0, h=0; h<l; h++) {
      if (!j) j = mode == FRAME ? D->P[i].lost : D->P[i].lost && (h == 0 || c == 'B' || c == 'P');
      if (!D->P[i].lost && D->P[i].t2 > tmax) tmax = D->P[i].t2;
      D->P[i++].type = c;
    }
	
    if (++D->nF > num) {
      num += 16384;
      if ((tmp = realloc(D->F, num * sizeof *D->F)) == 0) {
		  fprintf(stderr, "realloc error\n");
        return 0;
      }
      D->F = tmp;
    }

	// printf("D->F[%d].lost=%d D->F[%d].type=%c\n", D->nF-1, j, D->nF-1, c);

    D->F[D->nF-1] = null;
    D->F[D->nF-1].size = m;
    D->F[D->nF-1].lost = j;
    D->F[D->nF-1].type = c;
    D->F[D->nF-1].segm = l;
    D->F[D->nF-1].t1 = mode == FRAME ? D->P[ti].t1 : D->P[i-1].t1;
    D->F[D->nF-1].t2 = tmax; /* frame lost->t2:0; not lost: the received time of last packet of the frame */
  }
  fclose(f);

  return 1;
}
