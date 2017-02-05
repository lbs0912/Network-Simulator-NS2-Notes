#使用方法: ns lab5.tcl on-off資料流參數 第幾次實驗
#例如: ns lab5.tcl 100 1 (rate_設定為100k, 第一次實驗)

if {$argc !=2} {
	puts "Usage: ns lab5.tcl rate_ no_"
	exit
}

set par1 [lindex $argv 0]
set par2 [lindex $argv 1]

# 產生一個模擬的物件
set ns [new Simulator]

#開啟一個trace file，用來記錄封包傳送的過程
set nd [open out$par1-$par2.tr w]
$ns trace-all $nd

#定義一個結束的程序
proc finish {} {
        global ns nd
        $ns flush-trace
        close $nd 
        exit 0
}

#產生六個網路節點
set s1 [$ns node]
set s2 [$ns node]
set s3 [$ns node]
set d1 [$ns node]
set d2 [$ns node]
set d3 [$ns node]

#產生兩個路由器
set r1 [$ns node]
set r2 [$ns node]

#把節點和路由器連接起來
$ns duplex-link $s1 $r1 10Mb 1ms DropTail
$ns duplex-link $s2 $r1 10Mb 1ms DropTail
$ns duplex-link $s3 $r1 10Mb 1ms DropTail
$ns duplex-link $r1 $r2 1Mb 10ms DropTail
$ns duplex-link $r2 $d1 10Mb 1ms DropTail
$ns duplex-link $r2 $d2 10Mb 1ms DropTail
$ns duplex-link $r2 $d3 10Mb 1ms DropTail

#設定r1到r2之間的Queue Size為10個封包大小
#$ns queue-limit $r1 $r2 10

#建立一條s1-d1的TCP連線(FTP應用程式)
set tcp1 [new Agent/TCP]
$ns attach-agent $s1 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $d1 $sink1
$ns connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP
 
#建立一條s2-d2的TCP連線(FTP應用程式):干擾資料流
set tcp2 [new Agent/TCP]
$ns attach-agent $s2 $tcp2
set sink2 [new Agent/TCPSink]
$ns attach-agent $d2 $sink2
$ns connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ftp2 set type_ FTP

#建立一條on-off的干擾資料流,具有exponential distribution,平均的封包大小為1000bytes
#burst time:0.5秒, idle time:0秒,rate:為使用者設定的傳送速度
set udp [new Agent/UDP]
$ns attach-agent $s3 $udp
set null [new Agent/Null] 
$ns attach-agent $d3 $null
$ns connect $udp $null
set traffic [new Application/Traffic/Exponential]
$traffic set	packetSize_	1000
$traffic set	burst_time_	0.5
$traffic set	idle_time_	0
$traffic set 	rate_	[expr $par1*1000]
$traffic attach-agent $udp

#讓每次所產生的亂數都不相同
set rng [new RNG]
$rng seed 0

set RVstart [new RandomVariable/Uniform]
$RVstart set min_ 3
$RVstart set max_ 4
$RVstart use-rng $rng

#由亂數產生器去決定第一條flow的起始時間(在3~4秒之內)
set startT [expr [$RVstart value]]
puts "startT $startT sec"

#先讓干擾的資料流消耗網路的資源
$ns at 0.0 "$ftp2 start"
$ns at 0.0 "$traffic start"
$ns at $startT "$ftp1 start"

$ns at 11.0 "$ftp1 stop"
$ns at 11.5 "$ftp2 stop"
$ns at 11.5 "$traffic stop"

#在第12秒時去呼叫finish來結束模擬
$ns at 12.0 "finish"

#執行模擬
$ns run




