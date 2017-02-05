
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <math.h>
#include <float.h>

#include "misc.h"

int ToLower(int c)
{
  static const char lower[] = "abcdefghijklmnopqrstuvwxyz";
  static const char upper[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

  char *p = strchr(upper, c);
  return p ? lower[p - upper] : c;
}

int Max(unsigned ar[], int n, unsigned max_lim)
{
  int i, imax = 0;
  unsigned max = ar[0];

  for (i=1; i<n; i++)
    if (ar[i] < max_lim && ar[i] > max) {
      max = ar[i];
      imax = i;
    }

  return imax;
}

int Min(unsigned ar[], int n, unsigned min_lim)
{
  int i, imin = 0;
  unsigned min = ar[0];

  for (i=1; i<n; i++)
    if (ar[i] > min_lim && ar[i] < min) {
      min = ar[i];
      imin = i;
    }

  return imin;
}

unsigned Sum(unsigned ar[], int n)
{
  unsigned sum = 0;

  int i;
  for (i=0; i<n; i++) sum += ar[i];

  return sum;
}

int casecmp(const char *s, const char *t)
{
  while (*s && *t && ToLower(*s) == ToLower(*t)) {
    s++;
    t++;
  }
  return *s - *t;
}

char *dupstr(const char *s)
{
  size_t l = strlen(s) + 1;
  char *p = malloc(l);

  if (p) memcpy(p, s, l);

  return p;
}

char *skipc(char *p, const char *s)
{
  int i, f = 1;
  size_t l = strlen(s);

  while (f)
    for (f=0, i=0; i<l; i++)
      if (*p == s[i]) {
        p++;
        f = 1;
        break;
      }

  return p;
}

char *skips(char *p, const char *s, int n)
{
  int i;
  size_t l = strlen(s);

  for (i=0; i<n; i++)
    if ((p = strstr(p, s)) != 0) p += l;
    else break;

  return p;
}

char *getstr(char *buf, const char *search, char **ret)
{
  char *p, *q;

  if (p = skips(buf, search, 1)) {
    p = skipc(p, " \t=\"");
    if (q = strrchr(p, '\"')) *q = 0;
    return *ret = dupstr(p);
  }

  return 0;
}

unsigned getuint(char *buf, const char *search, unsigned *ret)
{
  char *p;

  if (p = skips(buf, search, 1)) {
    p = skipc(p, " \t=");
    return *ret = strtoul(p, 0, 10);
  }

  return 0;
}

double getdbl(char *buf, const char *search, double *ret)
{
  char *p;

  if (p = skips(buf, search, 1)) {
    p = skipc(p, " \t=");
    return *ret = strtod(p, 0);
  }

  return 0;
}

STATE getstate(char *buf, const char *search, STATE *ret)
{
  char *p, *q;

  if (p = skips(buf, search, 1)) {
    p = skipc(p, " \t=\"");
    if (q = strrchr(p, '\"')) *q = 0;
    return *ret = casecmp(p, "on") == 0 ? ON : OFF;
  }

  return INV;
}

void PrintByte(unsigned char x)
{
  int j = CHAR_BIT;

  while (j--) printf("%c", GETBIT(x,j)["01"]);
}

int CountBits(unsigned c)
{
  int n = 0;

  if (c)
    while (n++, c &= c-1)
      ;

  return n;
}

unsigned CalcMinBits(unsigned long n)
{
  unsigned l=0;

  if (n)
    while (l++, n >>= 1)
      ;

  return l;
}

void MeanBits(char **buf, unsigned l, char *c, unsigned size)
{
  unsigned i, j, k, n;

  for (i=0; i<size; i++)
    for (j=0; j<CHAR_BIT; j++) {
      for (n=0, k=0; k<l; k++) n += GETBIT(buf[k][i], j);
      if (n > l/2) SETBIT(c[i], j);
    }
}

void ClearPacks(unsigned char **pack, unsigned num, unsigned size)
{
  unsigned i, j;

  for (i=0; i<=num; i++) for (j=0; j<size; j++) pack[i][j] = 0;
}

int Corrupted(unsigned char **pack, unsigned char *mean, unsigned num, unsigned size)
{
  unsigned i, j, n;

  if (num < 3) return 1;

  for (i=0; i<size; i++) {
    for (j=0; j<num; j++) mean[i] += !!pack[j][i];
    mean[i] = mean[i] > num/2;
  }

  for (n=0, i=0; i<size; i++) n += mean[i];

  return !!n;
}

double ExpSmooth(tcpdump_t *pD, unsigned l, double a)
{
  unsigned i;
  double g;

  g = pD[0].snr[0];
  for (i=1; i<l; i++)
    g = a * pD[i].snr[0] + (1 - a) * g;

  return g;
}

double Avg(tcpdump_t *pD, DIR dir, int start, double off)
{
  int i = start, j = 0;
  double sum = 0;

  while (i >= 0 && pD[start].tr[dir] - pD[i].tr[dir] < off) {
    if (!pD[i].lost[dir]) {
      sum += pD[i].signal[dir];
      j++;
    }
    i--;
  }

  return j ? sum / j : 0;
}

double Std(tcpdump_t *pD, DIR dir, int start, double off, double avg)
{
  int i = start, j = 0;
  double v = 0;

  if (avg == DBL_MAX) avg = Avg(pD, dir, start, off);

  while (i >= 0 && pD[start].tr[dir] - pD[i].tr[dir] < off) {
    if (!pD[i].lost[dir]) {
      v += (pD[i].signal[dir] - avg) * (pD[i].signal[dir] - avg);
      j++;
    }
    i--;
  }

  return sqrt(j - 1 ? v / (j - 1) : 0);
}

void LinApprox(double *x, double *y, unsigned l, unsigned num, double *a, double *b)
{
  unsigned i;
  double sx = 0, sy = 0, sxx = 0, sxy = 0;

  if (num > l) num = l;

  for (i=l-num; i<l; i++) {
    sy += y[i];
    if (x) {
      sx += x[i];
      sxx += x[i] * x[i];
      sxy += x[i] * y[i];
    } else {
      sx += i;
      sxx += i * i;
      sxy += i * y[i];
    }
  }

  if (sxx * num - sx * sx != 0) {
    *a = (num * sxy - sy * sx) / (sxx * num - sx * sx);  /* Anstieg */
    *b = (sy - *a * sx) / num;                           /* Offset */
  }
}
