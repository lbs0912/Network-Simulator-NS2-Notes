BEGIN {
# Initialization. Set two variables.
  packetsize=1024;
}

{
   seq = $1;
   pkttype = $2;
   time = $3; 
   pktsize = $4;
   x = pktsize/packetsize;
   y = pktsize%packetsize;
   if(y!=0)
   	x=x+1;
   seg=x;
   printf("%d\t%c\t%d\t%d\n", seq, pkttype, pktsize, seg);
}

END {
}
