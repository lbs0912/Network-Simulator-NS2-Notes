#這是測量CBR封包jitter的awk程式
# jitter ＝((recvtime(j)-sendtime(j))-(recvtime(i)-sendtime(i)))/(j-i),其中 j>i

BEGIN {
#程式初始化，設定一變數以記錄目前最高處理封包的ID。
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

#記錄目前最高的packet ID
   if ( packet_id > highest_packet_id ) {
	   highest_packet_id = packet_id;
	}

#記錄封包的傳送時間
   if ( start_time[packet_id] == 0 )  {
	   # 記錄下包的seq_no
	   pkt_seqno[packet_id] = seq_no;
	   start_time[packet_id] = time;
   }

#記錄CBR (flow_id=2) 的接收時間
   if ( flow_id == 2 && action != "d" ) {
      if ( action == "r" ) {
	     end_time[packet_id] = time;
      }
    } else {
#把不是flow_id=2的封包或者是flow_id=2但此封包被丟棄的時間設為-1
      end_time[packet_id] = -1;
   }
}							  
END {
	# 初始化jitter計算所需變量
	last_seqno = 0;
	last_delay = 0;
	seqno_diff = 0;
#當資料列全部讀取完後，開始計算有效封包的端點到端點延遲時間 
    for ( packet_id = 0; packet_id <= highest_packet_id; packet_id++ ) {
       start = start_time[packet_id];
       end = end_time[packet_id];
       packet_duration = end - start;

#只把接收時間大於傳送時間的記錄列出來
       if ( start < end ) {
	       # 得到了delay值(packet_duration)後計算jitter
	       seqno_diff = pkt_seqno[packet_id] - last_seqno;
	       delay_diff = packet_duration - last_delay;
	       if (seqno_diff == 0) {
		       jitter =0;
	       } else {
		       jitter = delay_diff/seqno_diff;
	       }
	       printf("%f %f\n", start, jitter);
	       last_seqno = pkt_seqno[packet_id];
	       last_delay = packet_duration;
       }
    }
}
