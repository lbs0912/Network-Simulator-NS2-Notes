if {$argc !=1} {
	puts "Usage: ns lab11.tcl TCPversion "
	puts "Example:ns lab11.tcl Tahoe or ns lab11.tcl Reno"
	exit
}

set par1 [lindex $argv 0]

# 產生一個模擬的物件
set ns [new Simulator]

#開啟一個trace file，用來記錄封包傳送的過程
set nd [open out-$par1.tr w]
$ns trace-all $nd

#開啟一個檔案用來記錄cwnd變化情況
set f0 [open cwnd-$par1.tr w]

#定義一個結束的程序
proc finish {} {
        global ns nd f0 tcp
        
        #顯示最後的平均吞吐量
        puts [format "average throughput:%.1f Kbps" \
             [expr [$tcp set ack_]*([$tcp set packetSize_])*8/1000.0/10]]
        $ns flush-trace
	
	#關閉檔案
        close $nd
        close $f0
        exit 0
}

#定義一個記錄的程序
#每格0.01秒就去記錄當時的cwnd
proc record {} {
	global ns tcp f0
	
	set now [$ns now]
	puts $f0 "$now [$tcp set cwnd_]"
	$ns at [expr $now+0.01] "record"
}


#產生傳送節點,路由器r1,r2和接收節點
set n0 [$ns node]
set r0 [$ns node]
set r1 [$ns node]
set n1 [$ns node]

#建立鏈路
$ns duplex-link $n0 $r0 10Mb 1ms DropTail
$ns duplex-link $r0 $r1 1Mb  4ms DropTail
$ns duplex-link $r1 $n1 10Mb 1ms DropTail

#設定佇列長度為18個封包大小
set queue 18
$ns queue-limit $r0 $r1 $queue

#根據使用者的設定,指定TCP版本
if {$par1=="Tahoe"} {
	set tcp [new Agent/TCP]
} else {
	set tcp [new Agent/TCP/Reno]
}
$ns attach-agent $n0 $tcp

set tcpsink [new Agent/TCPSink]
$ns attach-agent $n1 $tcpsink

$ns connect $tcp $tcpsink

#建立FTP應用程式
set ftp [new Application/FTP]
$ftp attach-agent $tcp

#在0.0秒時,開始傳送
$ns at  0.0 "$ftp start"

#在10.0秒時,結束傳送
$ns at 10.0 "$ftp stop"

#在0.0秒時去呼叫record來記錄TCP的cwnd變化情況
$ns at 0.0 "record"

#在第10.0秒時去呼叫finish來結束模擬
$ns at 10.0 "finish"

#執行模擬
$ns run
