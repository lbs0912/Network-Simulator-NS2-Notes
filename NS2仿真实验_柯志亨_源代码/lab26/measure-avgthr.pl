#使用方法: perl measure-throughput.pl <trace file> <granlarity> 

#記錄檔檔名
$infile=$ARGV[0];

#多少時間計算一次(單位為秒)
$granularity=$ARGV[1];

$sum=0;
$sum_total=0;
$clock=0;
$maxrate=0;
$init=0;

#打開記錄檔
open (DATA,"<$infile")
    || die "Can't open $infile $!";
        
#讀取記錄檔中的每行資料,資料是以空白分成眾多欄位  
while (<DATA>) {
        @x = split(' ');
        
        if($init==0){
          $start=$x[2];
          $init=1;
	}
 
	#讀取的第零個欄位是pkt_id
#讀取的第一個欄位是封包傳送時間
#讀取的第二個欄位是封包接收時間
#讀取的第三個欄位是封包end to end delay
#讀取的第四個欄位是封包大小
	#判斷所讀到的時間,是否已經達到要統計吞吐量的時候
	if ($x[2]-$clock <= $granularity)
	{
		#計算單位時間內累積的封包大小
    		$sum=$sum+$x[4];
    		
   		#計算累積的總封包大小
    		$sum_total=$sum_total+$x[4];
	}
	else
	{
		#計算吞吐量 
	 	$throughput=$sum*8.0/$granularity;
	 	
	 	if ($throughput > $maxrate){
	 		$maxrate=$throughput;
	 	}
	 	
	 	    #輸出結果: 時間 吞吐量(bps)
    		#print STDOUT "$x[2]: $throughput bps\n";
    		
    		#設定下次要計算吞吐量的時間
    		$clock=$clock+$granularity;
    		
    		$sum_total=$sum_total+$x[4];
    		$sum=$x[4];
	}
}

$endtime=$x[2];
 
#計算最後一次的吞吐量大小   
$throughput=$sum*8.0/$granularity;
#print STDOUT "$x[2]: $throughput bps\n";
$clock=$clock+$granularity;
$sum=0;
#print STDOUT "$sum_total $start $endtime\n";
$avgrate=$sum_total*8.0/($endtime-$start);
print STDOUT "Average rate: $avgrate bps\n";
#print STDOUT "Peak rate: $maxrate bps\n";

#關閉檔案
close DATA;
exit(0);
