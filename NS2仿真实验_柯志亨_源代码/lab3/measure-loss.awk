#硂琌代秖CBR框ア瞯awk祘Α

BEGIN {
#祘Α﹍て,砞﹚跑计癘魁packet砆drop计ヘ
	fsDrops = 0;
	numFs = 0;
}
{
   action = $1;
   time = $2;
   from = $3;
   to = $4;
   type = $5;
   pktsize = $6;
   flow_id = $8;
   src = $9;
   dst = $10;
   seq_no = $11;
   packet_id = $12;

#参璸眖n1癳ぶpackets
	if (from==1 && to==2 && action == "+") 
		numFs++;
	
#参璸flow_id2,砆drop
	if (flow_id==2 && action == "d") 
		fsDrops++;
}
END {
	printf("number of packets sent:%d lost:%d\n", numFs, fsDrops);
}
