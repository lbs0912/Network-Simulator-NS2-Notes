# 这是测量CBR封包平均吞吐量（Average Throughput）的awk程序

BEGIN {
	# 程序初始化
	init = 0;
	i = 0;
}

{
	action = $1;
    time = $2;
    from = $3;
    to = $4;
    type = $5;
    pktsize = $6;
    flow_id = $8;
    src= $9;
    dst = $10;
    seq_no = $11;
    packet_id = $12;

	

	if(action == "r" && from == 2 && to == 3 && flow_id == 2) {

		pkt_byte_sum[i+1] = pkt_byte_sum[i]+pktsize;

		if(init == 0){
			start_time = time;
			init = 1;
		}

		end_time[i] = time;
		i = i+1;
	
	}
}

END {
	# 为了画图好看，把第一笔记录的Throughput设为０，以表示传输开始
	printf("%.2f\t%.2f\n",end_time[0],0);
	
	for(j=1;j<i;j++){
		# 单位为kbps
		th = pkt_byte_sum[j] / (end_time[j] - start_time) *8 /1000;
		printf("%.2f\t%.2f\n",end_time[j],th);
	}
	
	# 为了画图好看，把最后一笔记录的Throughput设为０，以表示传输结束
	printf("%.2f\t%.2f\n",end_time[i-1],0);
}




















