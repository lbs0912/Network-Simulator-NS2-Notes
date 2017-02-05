#使用方法: perl throughput.pl <trace file> <flow id> <granlarity> 

#記錄檔檔名
$infile=$ARGV[0];

#要計算平均速率的flow id
$flowid=$ARGV[1];

#多少時間計算一次(單位為秒)
$granularity=$ARGV[2];

$sum=0;
$clock=0;

#打開記錄檔
open (DATA,"<$infile")
    || die "Can't open $infile $!";
        
#讀取記錄檔中的每行資料,資料是以空白分成眾多欄位  
while (<DATA>) {
             @x = split(' ');

	#讀取的第二個欄位是時間
	#判斷所讀到的時間,是否已經達到要統計吞吐量的時候
	if ($x[1]-$clock <= $granularity)
	{
		#讀取的第一個欄位是動作
		#判斷動作是否是節點接收封包
		if ($x[0] eq 'r') 
		{ 
			#讀取的第八個欄位是flow id
			#判斷flow id是否為指定的id
			if ($x[7] eq $flowid) 
			{ 
    				#計算累積的封包大小
    				$sum=$sum+$x[5];
			}
		}
	}
	else
	{
		#計算吞吐量 
	 	$throughput=$sum*8.0/$granularity;
	 	
	 	#輸出結果: 時間 吞吐量(bps)
    		print STDOUT "$x[1]: $throughput bps\n";
    		
    		#設定下次要計算吞吐量的時間
    		$clock=$clock+$granularity;
    		
    		#把累積量規零
    		$sum=0;
	}   
}
 
#計算最後一次的吞吐量大小   
$throughput=$sum*8.0/$granularity;
print STDOUT "$x[1]: $throughput bps\n";
$clock=$clock+$granularity;
$sum=0;

#關閉檔案
close DATA;
exit(0);
 
