# 这是一条测量第一条TCP数据流封包端点到端点平均延迟的awk程序

BEGIN {
	#initialize
	highest_packet_id = 0;
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
	
	#save highest packet id
	if (packet_id >highest_packet_id) {
		highest_packet_id = packet_id;
	}

	# trace deliver time
	if (start_time[packet_id] == 0) {
		start_time[packet_id] = time;	
	}
	
	#　记录第一条TCP (flow_id = 0) 的接收时间
	if (flow_id == 0 && action != "d" && type == "tcp") {
		if (action == "r") {
			end_time[packet_id] = time;		
		}
	} else {
		# 把不是flow_id =　0 的封包或者是flow_id=0, 但此封包被drop的时间设为－１
		end_time[packet_id] = -1;	
	}
}

END {
	sum_delay = 0;
	no_sum = 0;
	
	# 当数据列全部读取完后,开始计算有效封包的端点到端点的延迟时间
	for (packet_id = 0; packet_id <= highest_packet_id; packet_id ++) {
		start = start_time[packet_id];
		end = end_time[packet_id];
		packet_duration = end - start;

		# 只把接收时间大于传送时间的记录列出来
		if (start < end) {
			#printf ("%f  %f \n",start,packet_duration);	
			sum_delay += packet_duration;
			no_sum += 1;	
		}	
	} 

	# 求出平均封包端点到端点的延迟时间
	printf("Average delay: %f sec \n", sum_delay/no_sum);
}













