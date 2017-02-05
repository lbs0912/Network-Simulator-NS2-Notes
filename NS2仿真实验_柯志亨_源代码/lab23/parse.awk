#分析不同路由協定的效能的AWK程式
BEGIN{
#程式初始化，設定一變數已記錄目前系統中最高處理封包的ID，
#及已經傳送及接收到的封包個數。
  	highest_packet_id=0;
	sends=0;
	receives=0;
	routing_packets=0;
	first_received_time=0;
	first=0;
}
{
	action = $1;
	time = $2;
	packet_id = $6;
	trace = $4;
	type = $7;
 		
	if(action=="s" || action== "r" || action=="f" )
	{
	    #記錄傳送出的封包個數
	    if(action=="s"&&trace=="AGT"&&type=="cbr")
            	{sends++;}

    	    #記錄目前系統中最高處理封包的ID
            if(packet_id > highest_packet_id) 
            	{highest_packet_id = packet_id;}

            #紀錄封包的傳送時間
            if(start_time[packet_id] == 0) 
            	{start_time[packet_id] = time;}
                     
            #紀錄接收到的封包個數及封包的接收時間
	    if (action =="r" && trace== "AGT" && type== "cbr")
	    {
	    	if(first==0){
	    		first_received_time= time;
	    		first=1;
	    	}
		receives++;
		end_time[packet_id] = time;
	    } else 
	    	end_time[packet_id] = -1;
         }
}

END{
          #計算有效封包的端點到端點延遲時間
         for (packet_id = 0; packet_id <= highest_packet_id ; packet_id++) {
           packet_duration = end_time[packet_id] - start_time[packet_id];
           if (packet_duration >0) end_to_end_delay += packet_duration;
         }
        #計算有效封包的平均端點到端點延遲時間
         avg_end_to_end_delay = end_to_end_delay / (receives);

         #計算封包送達比例
         pdfraction = (receives/sends)*100;
	
	#列出所有計算出的效能數據	
         printf(" Total packet sends: %d \n", sends);
         printf(" Total packet receives: %d \n", receives);
         printf(" Packet delivery fraction: %s \n", pdfraction);
         printf(" Average End-to-End delay:%f s \n" , avg_end_to_end_delay);
         printf(" first packet received time:%f s\n", first_received_time);     
}
