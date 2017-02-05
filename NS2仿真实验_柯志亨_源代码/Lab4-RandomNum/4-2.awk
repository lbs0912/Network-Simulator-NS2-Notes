BEGIN {
	# 程序初始化
	init = 0;
	startT = 0;
	endT = 0;	
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

	# 记录类型是tcp,动作类型是dequeue，且发生事件的时间介于1.0~5.0s
    # 由于新增结点时，其顺序为 r1 r2 s1 d1 s2 d2 s3 d3,所以相对的结点
	# id就是 0 1 2 3 4 5 6 7 
	if(action == "r" && type == "tcp" && time >= 1.0 && time <= 5.0 && 
		((from == 1 && to == 3) || (from == 1 && to == 5) || (from == 1 && to == 7))) {
			if (init == 0) {
				startT = time;
				init = 1;			
			}
	
			#　记录这段时间内离开队列的封包大小总和（in bytes）
			pkt_byte_sum += pktsize;
			endT = time;
	}
}

END {
	#计算1.0~5.0ｓ的平均带宽
	printf("startT:%f   endT:%f \n",startT,endT);
	printf("pkt_byte_sum:%d\n", pkt_byte_sum);
	time = endT - startT;
	throughput =  pkt_byte_sum *8/time/1000000;
	printf ("Throughput:%.3f Mbps \n",throughput);
}




















