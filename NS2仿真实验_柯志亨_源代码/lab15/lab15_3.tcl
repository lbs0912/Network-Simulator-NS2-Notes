if {$argc !=1} {
	puts "Usage: ns lab15_3.tcl Bandwidth(Mbps) "
	exit
}

#產生一個模擬的物件
set ns [new Simulator]

set bandwidth [lindex $argv 0]

#每秒可以處理的封包數(含TCP/IP Header)
set mu [expr $bandwidth*1000000/(8*552)]

#Round Trip Time
set tau [expr (1+18+1) * 2 * 0.001]

set beta .64

#設定buffer size為bandwidth-delay product的beta倍,
#以去觀察頻寬的使用率與ssthresh之間的關係
set B [expr $beta * ($mu * $tau + 1) + 0.5]

puts "Buffer size=$B"

#計算bandwidth-delay product
puts "Bandwidth-delay product=[expr $mu * $tau + 1]"

#開啟記錄檔，用來記錄封包傳送的過程
set nd [open out-ssthresh.tr w]
$ns trace-all $nd

set f1 [open sq-ssthresh.tr w]
set f2 [open throughput-ssthresh.tr w]
set f3 [open cwnd-ssthresh.tr w]

#定義一個結束的程序
proc finish {} {
        global ns nd f1 f2 tcp0 sink0 bandwidth
        $ns flush-trace
        
	#關閉檔案
        close $nd
        close $f1
        close $f2

	set now [$ns now]
	set ack [$tcp0 set ack_]
	set size [$tcp0 set packetSize_]
	set throughput [expr $ack*($size)*8/$now/1000000.0]
	set ut [expr ($throughput/$bandwidth)*100.0]
	
	#計算平均吞吐量
	puts [format "throughput=\t%.2f Mbps" $throughput]
	puts [format "utilization=\t%.1f " $ut]
       	exit 0
}

#定義一個記錄的程序
#每格0.05秒就去記錄當時的tcp的seqno_, cwnd,和throughput
proc record {} {
	global ns tcp0 sink0 f1 f2 f3
	
	set time 0.05
	set now [$ns now]
	
	set seq [$tcp0 set seqno_]
	set cwnd [$tcp0 set cwnd_]
	set bw [$sink0 set bytes_]
	puts $f1 "$now $seq"
	puts $f2 "$now [expr $bw*8/$now/1000]"
	puts $f3 "$now $cwnd"
	
	$ns at [expr $now+$time] "record"
}
	
#建立節點
set r0 [$ns node]
set r1 [$ns node]
set n0 [$ns node]
set n1 [$ns node]

#建立鏈路
set bd $bandwidth+Mb
$ns duplex-link $n0 $r0 100Mb 1ms DropTail
$ns duplex-link $r0 $r1 $bd 18ms DropTail
$ns duplex-link $r1 $n1 100Mb 1ms DropTail
$ns queue-limit $r0 $r1 $B

#建立FTP連線
set tcp0 [new Agent/TCP/Reno]
$ns attach-agent $n0 $tcp0
$tcp0 set window_ 64
$tcp0 set packetSize_ 512
set sink0 [new Agent/TCPSink]
$ns attach-agent $n1 $sink0
$ns connect $tcp0 $sink0
set ftp [new Application/FTP]
$ftp attach-agent $tcp0

$ns at 0.0 "$ftp start"
$ns at 30.0 "$ftp stop"
$ns at 0.05 "record"
$ns at 30.0 "finish"

#執行模擬
$ns run
