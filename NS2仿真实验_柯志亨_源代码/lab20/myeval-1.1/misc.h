#ifndef JKL_MISC
#define JKL_MISC

#include "def.h"

#define GETBIT(x,n) (!!((x) & 1U << (n)))
#define SETBIT(x,n) ((x) |= 1U << (n))
#define CLRBIT(x,n) ((x) &= ~(1U << (n)))

#define SCALEDB(x) (floor(((x) * 100. / 255 - 100)) + .5)
#define FROMDB(x) pow(10., (x) / 20.)
#define TODB(x) (20. * log10(x))

int Max(unsigned [], int, unsigned);
int Min(unsigned [], int, unsigned);
unsigned Sum(unsigned [], int);
int ToLower(int);
int casecmp(const char *, const char *);
char *dupstr(const char *);
char *skips(char *, const char *, int);
char *skipc(char *, const char *);
char *getstr(char *, const char *, char **);
unsigned getuint(char *, const char *, unsigned *);
double getdbl(char *, const char *, double *);
STATE getstate(char *, const char *, STATE *);
void PrintByte(unsigned char);
int CountBits(unsigned);
unsigned CalcMinBits(unsigned long);
void MeanBits(char **, unsigned, char *, unsigned);
void ClearPacks(unsigned char **, unsigned , unsigned);
int Corrupted(unsigned char **, unsigned char *, unsigned , unsigned);

double Avg(tcpdump_t *, DIR, int, double);
double Std(tcpdump_t *, DIR, int, double, double);

double ExpSmooth(tcpdump_t *pD, unsigned, double);
void LinApprox(double *, double *, unsigned, unsigned, double *, double *);

#endif
