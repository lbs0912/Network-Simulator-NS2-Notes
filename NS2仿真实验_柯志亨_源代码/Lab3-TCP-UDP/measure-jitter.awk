# 这是测量CBR封包jitter的awk程序

BEGIN {
	# 程序初始化，设置一变量以记录目前最高处理封包的ID
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
    src= $9;
    dst = $10;
    seq_no = $11;
    packet_id = $12;

	# 记录目前最高的packetID
    if(packet_id > highest_packet_id) 
		highest_packet_id = packet_id;

	#记录封包的传送时间
	if(start_time[packet_id] == 0) {

 		start_time[packet_id] = time;
		# 记录下包的seq_no
		pkt_seqno[packet_id] = seq_no;
	}
		
	# 记录CBR(flow_id=2)的接收时间
	if(flow_id == 2 && action != "d") {
		if(action == "r") {
			end_time[packet_id] = time;
		}	
	} else {
		#　把flow != 2的封包或者是flow_id = 2但此封包被drop的时间设为-1
		end_time[packet_id] = -1;
			
	} 
}

END {
	# 初始化jitter计算所需的变量
	last_seqno = 0;
	last_delay = 0;
	seqno_diff = 0;
	
	#　当数据行全部读取完后，开始计算有效封包的端点到端点的延迟时间
	for(packet_id = 0;packet_id <= highest_packet_id;packet_id++) {
		start = start_time[packet_id];
		end = end_time[packet_id];
		packet_duration = end - start;
		
		# 只把接收时间大于传送时间的记录列出来
		if(start < end) {
			#得到了delay值（packey_duration）后计算jitter
			seqno_diff = pkt_seqno[packet_id] - last_seqno;
			delay_diff = packet_duration - last_delay;
			if(seqno_diff == 0){
				jitter = 0;			
			}else{
				jitter = delay_diff/seqno_diff;
			}
			printf("%f %f\n",start,jitter);
			last_seqno = pkt_seqno[packet_id];
			last_delay = packet_duration;		
		}	
	}
}




















