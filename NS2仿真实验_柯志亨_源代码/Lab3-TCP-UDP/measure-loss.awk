# 这是测量CBR封包遗失率的awk程序

BEGIN {
	# 程序初始化，设置一变量以记录packet被drop的数目
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
    src= $9;
    dst = $10;
    seq_no = $11;
    packet_id = $12;

	# 统计从n1送出多少packets
	if(from==1 && to==2 && action=="+"){
		numFs++;	
	}

	# 统计 flow_id=2 且被drop的封包
	if(flow_id == 2 && action == "d") {
		fsDrops++;
	} 
}

END {
	printf("numbers of packets sent: %d  lost: %d \n",numFs,fsDrops);
}




















