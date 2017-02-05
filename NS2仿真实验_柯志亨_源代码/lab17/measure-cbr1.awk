#這是測量CBR封包平均吞吐量(average throughput)的awk程式(s2到dest)
BEGIN {
	init=0;
	i=0;
}
{
	action = $1;
   	time = $2;
   	node_1 = $3;
   	node_2 = $4;
   	src = $5;
   	pktsize = $6;
   	flow_id = $8;
   	node_1_address = $9;
   	node_2_address = $10;
   	seq_no = $11;
   	packet_id = $12;
   
 	if(action=="r" && node_1==4 && node_2==5 && flow_id==2) {
 		pkt_byte_sum[i+1]=pkt_byte_sum[i]+ pktsize;
		
		if(init==0) {
			start_time = time;
			init = 1;
		}
		
		end_time[i] = time;
		i = i+1;
	}
}
END {
#為了畫圖好看，把第一筆記錄的throughput設為零，以表示傳輸開始
	printf("%.2f\t%.2f\n", end_time[0], 0);
	
	for(j=1 ; j<i ; j++){
#單位為kbps
		th = pkt_byte_sum[j] / (end_time[j] - start_time)*8/1000;
		printf("%.2f\t%.2f\n", end_time[j], th);
	}
#為了畫圖好看，把第後一筆記錄的throughput再設為零，以表示傳輸結束
	printf("%.2f\t%.2f\n", end_time[i-1], 0);
}
