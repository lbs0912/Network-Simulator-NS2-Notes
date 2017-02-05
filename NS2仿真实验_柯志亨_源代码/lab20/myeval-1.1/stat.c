
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <float.h>
#include <math.h>

#include "def.h"
#include "stat.h"

void CalcLoss(dump_t *pD, unsigned l, loss_t *pS, char *id)
{
  FILE *f;
  unsigned long i;
  char s[32];
 
  pS->nH=0; pS->nI=0; pS->nP=0; pS->nB=0;
  pS->lH=0; pS->lI=0; pS->lP=0; pS->lB=0;

  for (i=0; i<l; i++)
    switch (pD[i].type) {
      case 'H': pS->nH++; if (pD[i].lost) pS->lH++; break;
      case 'I': pS->nI++; if (pD[i].lost) pS->lI++; break;
      case 'P': pS->nP++; if (pD[i].lost) pS->lP++; break;
      case 'B': pS->nB++; if (pD[i].lost) pS->lB++; break;
      default : break;
    }

  pS->nA = pS->nH + pS->nI + pS->nP + pS->nB;
  pS->lA = pS->lH + pS->lI + pS->lP + pS->lB;
  
  if(id){
    /* frame level */
	printf("Frame sent:f->nA:%d, f->nI:%d, f->nP:%d, f->nB:%d \n", pS->nA, pS->nI, pS->nP, pS->nB);
	printf("Frame lost:f->lA:%d, f->lI:%d, f->lP:%d, f->lB:%d \n", pS->lA, pS->lI, pS->lP, pS->lB);
  } else {
   /* packet level*/
	printf("Packet sent:p->nA:%d, p->nI:%d, p->nP:%d, p->nB:%d \n", pS->nA, pS->nI, pS->nP, pS->nB);
	printf("Packet lost:p->lA:%d, p->lI:%d, p->lP:%d, p->lB:%d \n", pS->lA, pS->lI, pS->lP, pS->lB);
  }
}

void CalcJitter(dump_t *pD, unsigned l)
{
  int i, j;
  double tmp;

  /* t1: send time, t2:received time */
  /* d1: t2-t1 when no frame/packet lost */
  for (i=0; i<l; i++)
    pD[i].d1 = pD[i].lost ? 0 : pD[i].t2 - pD[i].t1;

  for (i=1; i<l; i++) {
    pD[i].j1 = pD[i].t1 - pD[i-1].t1;
    pD[i].j2 = pD[i].lost || pD[i-1].lost ? 0 : pD[i].t2 - pD[i-1].t2;

    tmp = pD[i].j2;

	/* when lost occurs */
    if (!tmp)
      if (!pD[i].lost) {
        for (j=i-1; j>=0; j--)
          if (!pD[j].lost) {
            tmp = pD[i].t2 - pD[j].t2;
            break;
          }
      }/* else tmp = pD[i].j1;*/
   
	/* frame/packet jitter */
    pD[i].d2 = tmp - pD[i].j1;
  }

  pD[0].j1 = 0;
  pD[0].j2 = 0;
}

void OutJitter(dump_t *pD, unsigned l, char *id)
{
  FILE *f=0;
  unsigned i;
  double cjit = 0;
  char s[32];

    if (id) 
    	sprintf(s, "delay_%s.txt", id);
    else
    	sprintf(s, "delay_pkt.txt");
    	
    if ((f = fopen(s, "w")) == 0) {
      fprintf(stderr, "error opening %s\n", s);
      return;
    }
    for (i=0; i<l; i++) {
	  /* d2: jitter, cjit:cumulative jitter */
      cjit += pD[i].d2;
	  /* format:frame seqno, set to 0 when not lost, transmission time,send time difference, received time difference, cumulative jitter */
      /* fprintf(f, "%u\t%d\t%.6f\t%.6f\t%.6f\t%.6f\n", i, pD[i].lost, pD[i].d1, pD[i].j1, pD[i].j2, cjit); */
	  if(pD[i].lost==0){
		  fprintf(f, "%u\t%.6f\t%.6f\n", i, pD[i].d1, pD[i].d2);
	  }
    }
    fclose(f);
 // }
}

void PoBLoss(data_t *D, double PoB)
{
  double cjit = 0, tdrop = PoB;
  unsigned i;

  for (i=1; i<D->nF; i++) {
    cjit += D->F[i].d2;
	/* printf("cjit:%f, tdrop:%f\n",cjit,tdrop); */
    if (!D->F[i].lost && cjit > tdrop)
      D->F[i].lost = 1;
  }
}

void CaldecodableFrame_GOP12(dump_t *pD, unsigned l, char *id)
{
  unsigned i, j;
  int  decodable_i=0, decodable_p1=0, decodable_p2=0, decodable_p3=0, decodable_next_i=0;
  unsigned long total_I_frame=0, total_P_frame=0, total_B_frame=0;
  unsigned long total_dI_frame=0, total_dP_frame=0, total_dB_frame=0; /* directly decodable frames */
  unsigned long decodable_frame=0, decodable_I_frame=0, decodable_P_frame=0, decodable_B_frame=0;

  if(pD[0].lost==0) {
	  decodable_i=1;
	  decodable_frame+=1;
	  decodable_I_frame+=1;
	  total_dI_frame+=1;
	  total_I_frame+=1;
  } else {
	  total_I_frame+=1;
	  decodable_i=0;
  }

  if(pD[1].lost==0) 
	  total_dP_frame+=1;

  if(pD[4].lost==0) 
	  total_dP_frame+=1;

  if(pD[7].lost==0) 
	  total_dP_frame+=1;

  if(decodable_i==1 && pD[1].lost==0) {
	  decodable_p1=1;
	  decodable_frame+=1;
	  decodable_P_frame+=1;
	  total_P_frame+=1;
  } else {
	  decodable_p1=0;
	  total_P_frame+=1;
  }

  if(decodable_p1==1 && pD[4].lost==0) {
	  decodable_p2=1;
	  decodable_frame+=1;
	  decodable_P_frame+=1;
	  total_P_frame+=1;
  } else {
	  decodable_p2=0;
	  total_P_frame+=1;
  }

  if(decodable_p2==1 && pD[7].lost==0) {
	  decodable_p3=1;
	  decodable_frame+=1;
	  decodable_P_frame+=1;
	  total_P_frame+=1;
  } else {
	  decodable_p3=0;
	  total_P_frame+=1;
  }
  
  if(pD[2].lost==0) 
	  total_dB_frame+=1;

  if(pD[3].lost==0) 
	  total_dB_frame+=1;

  if(pD[5].lost==0) 
	  total_dB_frame+=1;

  if(pD[6].lost==0) 
	  total_dB_frame+=1;

  if(pD[8].lost==0) 
	  total_dB_frame+=1;

  if(pD[9].lost==0) 
	  total_dB_frame+=1;

  if(pD[11].lost==0) 
	  total_dB_frame+=1;

  if(pD[12].lost==0) 
	  total_dB_frame+=1;

  if(decodable_i==1 && decodable_p1==1 && pD[2].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
  }else{
	  total_B_frame+=1;
  }

  if(decodable_i==1 && decodable_p1==1 && pD[3].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
  }else{
	  total_B_frame+=1;
  }

  if(decodable_p1==1 && decodable_p2==1 && pD[5].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
  }else{
	  total_B_frame+=1;
  }

  if(decodable_p1==1 && decodable_p2==1 && pD[6].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
  }else{
	  total_B_frame+=1;
  }

  if(decodable_p2==1 && decodable_p3==1 && pD[8].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
  }else{
	  total_B_frame+=1;
  }

  if(decodable_p2==1 && decodable_p3==1 && pD[9].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
  }else{
	  total_B_frame+=1;
  }

  if(decodable_p3==1 && pD[10].lost==0 && pD[11].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
  }else{
	  total_B_frame+=1;
  }

  if(decodable_p3==1 && pD[10].lost==0 && pD[12].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
  }else{
	  total_B_frame+=1;
  }

  i=13;
  j=0;
  
  while(1) {
	if(pD[10+12*j].lost==0) {
	  decodable_i=1;
	  decodable_frame+=1;
	  decodable_I_frame+=1;
	  total_dI_frame+=1;
	  total_I_frame+=1;
	} else {
	  decodable_i=0;
	  total_I_frame+=1;
	}

	if(++i==l)	
		break;

	if(pD[13+12*j].lost==0) 
	  total_dP_frame+=1;

	if(decodable_i==1 && pD[13+12*j].lost==0){
		decodable_p1=1;
		decodable_frame+=1;
		decodable_P_frame+=1;
		total_P_frame+=1;
	} else {
		decodable_p1=0;
		total_P_frame+=1;
	}

	if(++i==l)	
		break;

	if(pD[14+12*j].lost==0) 
	  total_dB_frame+=1;

	if(decodable_i==1 && decodable_p1==1 && pD[14+12*j].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
	}else{
	  total_B_frame+=1;
	}

	if(++i==l)	
		break;

	if(pD[15+12*j].lost==0) 
	  total_dB_frame+=1;

	if(decodable_i==1 && decodable_p1==1 && pD[15+12*j].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
	}else{
	  total_B_frame+=1;
	}

	if(++i==l)	
		break;

	if(pD[16+12*j].lost==0) 
	  total_dP_frame+=1;

	if(decodable_p1==1 && pD[16+12*j].lost==0){
		decodable_p2=1;
		decodable_frame+=1;
		decodable_P_frame+=1;
		total_P_frame+=1;
	} else {
		decodable_p2=0;
		total_P_frame+=1;
	}

	if(++i==l)	
		break;

	if(pD[17+12*j].lost==0) 
	  total_dB_frame+=1;
	
	if(decodable_p1==1 && decodable_p2==1 && pD[17+12*j].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
	}else{
	  total_B_frame+=1;
	}
	
	if(++i==l)	
		break;

	if(pD[18+12*j].lost==0) 
	  total_dB_frame+=1;
	
	if(decodable_p1==1 && decodable_p2==1 && pD[18+12*j].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
	}else{
	  total_B_frame+=1;
	}

	if(++i==l)	
		break;

	if(pD[19+12*j].lost==0) 
		total_dP_frame+=1;

	if(decodable_p2==1 && pD[19+12*j].lost==0){
		decodable_p3=1;
		decodable_frame+=1;
		decodable_P_frame+=1;
		total_P_frame+=1;
	} else {
		decodable_p3=0;
		total_P_frame+=1;
	}

	if(++i==l)	
		break;

	if(pD[20+12*j].lost==0) 
	  total_dB_frame+=1;
	
	if(decodable_p2==1 && decodable_p3==1 && pD[20+12*j].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
	}else{
	  total_B_frame+=1;
	}

	if(++i==l)	
		break;
   
	if(pD[21+12*j].lost==0) 
	  total_dB_frame+=1;

	if(decodable_p2==1 && decodable_p3==1 && pD[21+12*j].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
	}else{
	  total_B_frame+=1;
	}
	
	if(++i==l)	
		break;

	if(pD[23+12*j].lost==0) 
	  total_dB_frame+=1;

	if(decodable_p3==1 && pD[22+12*j].lost==0 && pD[23+12*j].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
	}else{
	  total_B_frame+=1;
	}
	
	if(++i==l)	
		break;

	if(pD[24+12*j].lost==0) 
	  total_dB_frame+=1;
	
	if(decodable_p3==1 && pD[22+12*j].lost==0 && pD[24+12*j].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
	}else{
	  total_B_frame+=1;
	}

	if(++i==l)	
		break;

	j+=1;
  }

  /* printf("i:%d, j:%d\n", i, j); */
  printf("\nResult:\n");
  printf("total_frame:%ld decodable_frame:%ld Q:%lf\n", l, decodable_frame, (float)decodable_frame/l);
  printf("total directly decodable frame: I->%ld, P->%ld, B->%ld\n", total_dI_frame, total_dP_frame, total_dB_frame);
  printf("total decodable frame: I->%ld, P->%ld, B->%ld\n", decodable_I_frame, decodable_P_frame, decodable_B_frame);
  printf("total frame: I->%ld, P->%ld, B->%ld\n", total_I_frame, total_P_frame, total_B_frame);
}

void CaldecodableFrame_GOP9(dump_t *pD, unsigned l, char *id)
{
	/* for ffmpeg */
  unsigned i, j;
  int  decodable_i=0, decodable_p1=0, decodable_p2=0, decodable_next_i=0;
  unsigned long total_I_frame=0, total_P_frame=0, total_B_frame=0;
  unsigned long total_dI_frame=0, total_dP_frame=0, total_dB_frame=0; /* directly decodable frames */
  unsigned long decodable_frame=0, decodable_I_frame=0, decodable_P_frame=0, decodable_B_frame=0;

  if(pD[0].lost==0) {
	  decodable_i=1;
	  decodable_frame+=1;
	  decodable_I_frame+=1;
	  total_dI_frame+=1;
	  total_I_frame+=1;
  } else {
	  total_I_frame+=1;
	  decodable_i=0;
  }

  if(pD[1].lost==0) 
	  total_dP_frame+=1;

  if(pD[4].lost==0) 
	  total_dP_frame+=1;


  if(decodable_i==1 && pD[1].lost==0) {
	  decodable_p1=1;
	  decodable_frame+=1;
	  decodable_P_frame+=1;
	  total_P_frame+=1;
  } else {
	  decodable_p1=0;
	  total_P_frame+=1;
  }

  if(decodable_p1==1 && pD[4].lost==0) {
	  decodable_p2=1;
	  decodable_frame+=1;
	  decodable_P_frame+=1;
	  total_P_frame+=1;
  } else {
	  decodable_p2=0;
	  total_P_frame+=1;
  }
  
  if(pD[2].lost==0) 
	  total_dB_frame+=1;

  if(pD[3].lost==0) 
	  total_dB_frame+=1;

  if(pD[5].lost==0) 
	  total_dB_frame+=1;

  if(pD[6].lost==0) 
	  total_dB_frame+=1;

  if(pD[8].lost==0) 
	  total_dB_frame+=1;

  if(pD[9].lost==0) 
	  total_dB_frame+=1;

  if(decodable_i==1 && decodable_p1==1 && pD[2].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
  }else{
	  total_B_frame+=1;
  }

  if(decodable_i==1 && decodable_p1==1 && pD[3].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
  }else{
	  total_B_frame+=1;
  }

  if(decodable_p1==1 && decodable_p2==1 && pD[5].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
  }else{
	  total_B_frame+=1;
  }

  if(decodable_p1==1 && decodable_p2==1 && pD[6].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
  }else{
	  total_B_frame+=1;
  }

  if(decodable_p2==1 && pD[7].lost==0 && pD[8].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
  }else{
	  total_B_frame+=1;
  }

  if(decodable_p2==1 && pD[7].lost==0 && pD[9].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
  }else{
	  total_B_frame+=1;
  }

  i=10;
  j=0;
  
  while(1) {
	if(pD[7+9*j].lost==0) {
	  decodable_i=1;
	  decodable_frame+=1;
	  decodable_I_frame+=1;
	  total_dI_frame+=1;
	  total_I_frame+=1;
	} else {
	  decodable_i=0;
	  total_I_frame+=1;
	  // printf("lost I frame:%d\n", (7+9*j));
	}

	if(++i==l)	
		break;

	if(pD[10+9*j].lost==0) 
	  total_dP_frame+=1;

	if(decodable_i==1 && pD[10+9*j].lost==0){
		decodable_p1=1;
		decodable_frame+=1;
		decodable_P_frame+=1;
		total_P_frame+=1;
	} else {
		decodable_p1=0;
		total_P_frame+=1;
	}

	if(++i==l)	
		break;

	if(pD[11+9*j].lost==0) 
	  total_dB_frame+=1;

	if(decodable_i==1 && decodable_p1==1 && pD[11+9*j].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
	}else{
	  total_B_frame+=1;
	}

	if(++i==l)	
		break;

	if(pD[12+9*j].lost==0) 
	  total_dB_frame+=1;

	if(decodable_i==1 && decodable_p1==1 && pD[12+9*j].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
	}else{
	  total_B_frame+=1;
	}

	if(++i==l)	
		break;

	if(pD[13+9*j].lost==0) 
	  total_dP_frame+=1;

	if(decodable_p1==1 && pD[13+9*j].lost==0){
		decodable_p2=1;
		decodable_frame+=1;
		decodable_P_frame+=1;
		total_P_frame+=1;
	} else {
		decodable_p2=0;
		total_P_frame+=1;
	}

	if(++i==l)	
		break;

	if(pD[14+9*j].lost==0) 
	  total_dB_frame+=1;
	
	if(decodable_p1==1 && decodable_p2==1 && pD[14+9*j].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
	}else{
	  total_B_frame+=1;
	}
	
	if(++i==l)	
		break;

	if(pD[15+9*j].lost==0) 
	  total_dB_frame+=1;
	
	if(decodable_p1==1 && decodable_p2==1 && pD[15+9*j].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
	}else{
	  total_B_frame+=1;
	}

	if(++i==l)	
		break;

	if(pD[17+9*j].lost==0) 
	  total_dB_frame+=1;

	if(decodable_p2==1 && pD[16+9*j].lost==0 && pD[17+9*j].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
	}else{
	  total_B_frame+=1;
	}
	
	if(++i==l)	
		break;

	if(pD[18+9*j].lost==0) 
	  total_dB_frame+=1;
	
	if(decodable_p2==1 && pD[16+9*j].lost==0 && pD[18+9*j].lost==0) {
	  decodable_frame+=1;
	  decodable_B_frame+=1;
	  total_B_frame+=1;
	}else{
	  total_B_frame+=1;
	}
	
	if(++i==l)	
		break;

	j+=1;
  }

  // printf("i:%d, j:%d\n", i, j); 

  printf("\nResult:\n");
  printf("total_frame:%ld decodable_frame:%ld Q:%lf\n", l, decodable_frame, (float)decodable_frame/(l-1));
  printf("total directly decodable frame: I->%ld, P->%ld, B->%ld\n", total_dI_frame, total_dP_frame, total_dB_frame);
  printf("total decodable frame: I->%ld, P->%ld, B->%ld\n", decodable_I_frame, decodable_P_frame, decodable_B_frame);
  printf("total frame: I->%ld, P->%ld, B->%ld\n", total_I_frame, total_P_frame, total_B_frame);
}
