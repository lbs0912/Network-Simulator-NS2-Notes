#使用方法: perl measure-TCP.pl <trace file> <granlarity> 

#記錄檔檔名
$infile=$ARGV[0];

#多少時間計算一次(單位為秒)
$granularity=$ARGV[1];

$sum=0;
$sum_total=0;
$clock=0;
$init=0;

#打開記錄檔
open (DATA,"<$infile")
    || die "Can't open $infile $!";
        
#讀取記錄檔中的每行資料,資料是以空白分成眾多欄位  
while (<DATA>) {
        @x = split(' ');
        
        if($init==0){
          $start=$x[1];
          $init=1;
	}

	#讀取的第零個欄位是pkt_id
#讀取的第一個欄位是封包接收時間
#讀取的第二個欄位是封包大小
#判斷所讀到的時間,是否已經達到要統計吞吐量的時候
	if ($x[1]-$clock <= $granularity)
	{
		#計算單位時間內累積的封包大小
    		$sum=$sum+$x[2];

   		#計算累積的總封包大小
    		$sum_total=$sum_total+$x[2];
	}
	else
	{
		#計算吞吐量 
	 	$throughput=$sum*8.0/$granularity;
	 	
	 	#輸出結果: 時間 吞吐量(bps)
    		print STDOUT "$x[1] $throughput\n";
    		
    	#設定下次要計算吞吐量的時間
    		$clock=$clock+$granularity;		
    	    
            $sum_total=$sum_total+$x[2];
	$sum=$x[2];
	}   
}

$endtime=$x[1];
 
#計算最後一次的吞吐量大小   
$throughput=$sum*8.0/$granularity;
print STDOUT "$x[1] $throughput\n";
$clock=$clock+$granularity;
$sum=0;
print STDOUT "$sum_total $start $endtime\n";
$avgrate=$sum_total*8.0/($endtime-$start);
print STDOUT "Average rate: $avgrate bps\n";

#關閉檔案
close DATA;
exit(0);
