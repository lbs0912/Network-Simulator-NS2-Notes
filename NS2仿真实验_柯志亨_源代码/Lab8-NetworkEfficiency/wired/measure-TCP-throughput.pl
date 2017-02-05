# Usage: perl measure-TCP-throughput.pl <trace file><granlarity>

# 记录文件文件名
$infile = $ARGV[0];
# 多少时间计算一次（单位：ｓ）
$granularity = $ARGV[1];

$sum = 0;
$sum_total = 0;
$clock = 0;
$maxrate = 0;
$init = 0;

# 打开记录文件
open (DATA,"<$infile")
	|| die "Can't open $infile $!";

#读取记录文件中的每行数据，数据是以空白分成众多字段
while (<DATA>) {
	@x = split(' ');
	
	if($init==0){
		$start=$x[1];
		$init =1;		
	}


	#　读取的第０个字段是pkt_id
	#　读取的第1个字段是封包传送时间
	#　读取的第２个字段是封包接收时间
	#　读取的第３个字段是封包end_to_end delay
	#  读取的第4个字段是封包大小
	# 判断所读到的时间，是否已经达到要统计吞吐量的时候
	if($x[1]-$clock <= $granularity){
		#计算单位时间内累计的封包大小
		$sum = $sum+$x[2];
		
		#计算累积的总封包大小
		$sum_total = $sum_total+$x[2];
	}
	else{
		#计算吞吐量
		$throughput = $sum*8.0/$granularity;

		if($throughput>$maxrate){
			$maxrate = $throughput;		
		}

		#输出结果：时间　吞吐量 (bps)
		print STDOUT "$x[1]:$throughput bps\n";
		
		#设置下次要计算吞吐量的时间
		$clock = $clock + $granularity;

		$sum_total = $sum_total+$x[2];
		$sum = $x[2];
	}
}

$endtime = $x[1];

# 计算最后一次的吞吐量大小
$throughput = $sum*8.0/$granularity;
print STDOUT "$x[1]:$throughput bps\n";
$clock = $clock + $granularity;
$sum = 0;
print STDOUT "$sum_total  $start  $endtime \n";
$avgrate = $sum_total * 8.0/($endtime-$start);
print STDOUT "Average rate: $avgrate bps\n";
print STDOUT "Peak rate: $maxrate bps\n";

# close file
close DATA;
exit(0); 





















