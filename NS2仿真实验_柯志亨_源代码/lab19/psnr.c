
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

int main(int n, char *cl[])
{
  FILE *f1, *f2;
  int i, x, y, yuv, inc = 1, size = 0, N = 0, Y, F;
  double yrmse, diff, mean = 0, stdv = 0, *ypsnr = 0;
  unsigned char *b1, *b2;
  int k=1;
  clock_t t = clock();

  if (n != 6 && n != 7) {
    puts("psnr x y <YUV format> <src.yuv> <dst.yuv> [multiplex]");
    puts("  x\t\tframe width");
    puts("  y\t\tframe height");
    puts("  YUV format\t420, 422, etc.");
    puts("  src.yuv\tsource video");
    puts("  dst.yuv\tdistorted video");
    puts("  [multiplex]\toptional");
    return EXIT_FAILURE;
  }

  if ((f1 = fopen(cl[4],"rb")) == 0) goto A;
  if ((f2 = fopen(cl[5],"rb")) == 0) goto B;
  if (!(x = strtoul(cl[1], 0, 10)) ||
      !(y = strtoul(cl[2], 0, 10))) goto C; 
  if ((yuv = strtoul(cl[3], 0, 10)) > 444) goto D;
  if (cl[6] && !strcmp(cl[6], "multiplex")) inc = 2;

  Y = x * y;
  switch (yuv) {
    case 400: F = Y; break;
    case 422: F = Y * 2; break;
    case 444: F = Y * 3; break;
    default :
    case 420: F = Y * 3 / 2; break;
  }

  if (!(b1 = malloc(F))) goto E;
  if (!(b2 = malloc(F))) goto E;

  for (;;) {
    if (1 != fread(b1, F, 1, f1) || 1 != fread(b2, F, 1, f2)) break;
    for (yrmse=0, i=inc-1; i<(inc==1 ? Y : F); i+=inc) {
      diff = b1[i] - b2[i];
      yrmse += diff * diff;
    }
    if (++N > size) {
      size += 0xffff;
      if (!(ypsnr = realloc(ypsnr, size * sizeof *ypsnr))) goto E;
    }

    mean += ypsnr[N-1] = yrmse ? 20 * (log10(255 / sqrt(yrmse / Y))) : 0;
    printf("%d\t%.2f\n", k++, ypsnr[N-1]);
  }

  if (N) {
    mean /= N;

    for (stdv=0, i=0; i<N; i++) {
      diff = ypsnr[i] - mean;
      stdv += diff * diff;
    }
    stdv = sqrt(stdv / (N - 1));

    free(ypsnr);
  }

  fclose(f1);
  fclose(f2);

  //fprintf(stderr, "psnr:\t%d frames (CPU: %lu s) mean: %.2f stdv: %.2f\n",
  //  N, (unsigned long) ((clock() - t) / CLOCKS_PER_SEC), mean, stdv);

  return 0;

A: fprintf(stderr, " Error opening sourcefile.\n"); goto X;
B: fprintf(stderr, " Error opening decodedfile.\n"); goto X;
C: fprintf(stderr, " Invalid width or height.\n"); goto X;
D: fprintf(stderr, " Invalid YUV format.\n"); goto X;
E: fprintf(stderr, " Not enough memory.\n");

X: return EXIT_FAILURE;
}

