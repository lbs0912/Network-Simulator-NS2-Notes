BEGIN {
	init=0;
        startT=0;
	endT=0;
}

{
         action = $1;
         time = $2;
         from = $3;
         to = $4;
         type = $5;
         pktsize = $6;
         flow_id = $8;
         node_1_address = $9;
         node_2_address = $10;
         seq_no = $11;
         packet_id = $12;

#計算s1-d1這條flow在5~10秒之間,d1接收了多少的資料量.s1的id為7,d1的id為3
         if(action=="r" && type=="tcp" && time >= 5.0 && time <=10.0 && (from==7 && to==3)) {
         	 if(init==0){
         	 	startT=time;
         	 	init=1;
         	 }
         	 
#記錄在這段時間中離開佇列的封包大小總和 (in bytes)
	         pkt_byte_sum += pktsize;
	         endT=time;
         }
    
         
}

END {
#計算5~10秒的Throughput
#	printf("\n");
#	printf("startT:%f endT:%f\n", startT, endT);
#	printf("pkt_byte_sum:%d\n", pkt_byte_sum);
	time=endT-startT;
	throughput=pkt_byte_sum*8/time/1000;
#	printf("throughput:%.3f kbps\n", throughput);
	printf("%f\n", throughput);
}

