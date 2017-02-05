#ifndef JKL_DEF
#define JKL_DEF

#define L 152064 /* (352 * 288 * 1.5) */
#define MC 10000
#define CN 20
#define TT .001 /* Time Tolerance [s] */

#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define MIN(a, b) ((a) < (b) ? (a) : (b))

typedef struct {
  unsigned id, size, retry, rest, segm;
  double t1, t2, j1, j2, d1, d2;
  char type, lost, signal, noise;
} dump_t;

typedef struct {
  unsigned id[2];
  double ts[2], tr[2], snr[2], js[2], jr[2];
  char insd[2], lost[2], signal[2], noise[2];
} tcpdump_t;

typedef struct {
  unsigned size, id[2];
  double t[2];
} TCPdump_t;

typedef struct {
  double t[2], signal[2], avg[2];
} AVG_t;

typedef struct {
  dump_t *P, *F;
  unsigned long nP, nF;
} data_t;

typedef struct {
  TCPdump_t *P;
  unsigned long nP;
} cDump_t;

typedef struct {
  tcpdump_t *P;
  unsigned long nP;
} snr_t;

typedef struct {
  AVG_t *P;
  unsigned long nP;
} avg_t;

typedef struct {
  unsigned long lH, lI, lP, lB, lA, nH, nI, nP, nB, nA;
  struct { unsigned long size, lost, I, P, B; } cl[MC];
} loss_t;

typedef enum {INV, ON, OFF} STATE;
typedef enum {FRAME, PACKET} MODE;
typedef enum {TO_MOBILE, FROM_MOBILE, MATCH_IDS, CHECK_IDS} DIR;

typedef struct {
  double deadline, I_dl, P_dl, B_dl, I_wgt, P_wgt, B_wgt, mix;
  unsigned wt, subs, alg, sig;
  STATE vbr, prio, vrth, balance;
  char *chn_file, *sd[2], *st[2], *res_path[2];
} param_t;

#endif
