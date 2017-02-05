# awk分析程序（measure-jitter.awk）

BEGIN {
	last_pkt_id = -1;
	last_e2e_delay = -1;
}

{
	pkt_id = $1;
	send_time = $2;
	rcv_time = $3;
	e2e_delay = $4;
	pkt_size = $5;

	if(last_pkt_id != -1) {
		jitter = (e2e_delay - last_e2e_delay) / (pkt_id - last_pkt_id);
		printf("%f  %f\n",send_time,jitter);
	}

	last_pkt_id = pkt_id;
	last_e2e_delay = e2e_delay;	
}

{

}
