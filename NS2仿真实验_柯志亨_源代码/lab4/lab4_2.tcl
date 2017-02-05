set ns [new Simulator]

#開啟一個trace file，用來記錄封包傳送的過程
set nd [open out.tr w]
$ns trace-all $nd

#設定TCP flow的數目
set nflow	3

#設定路由器
set r1 [$ns node]
set r2 [$ns node]
$ns duplex-link $r1 $r2 1Mb 10ms DropTail

#設定TCP來源節點
#設定TCP目的節點
#建立來源和目的節點與路由器的鏈路
for {set i 1} { $i <= $nflow } { incr i } {

	set s($i) [$ns node]
	set d($i) [$ns node]
	
	$ns duplex-link $s($i) $r1 10Mb 1ms DropTail 
	$ns duplex-link $r2 $d($i) 10Mb 1ms DropTail
}

#建立TCP的連線,並在TCP連線上建立FTP應用程式
for {set i 1} {$i <= $nflow} {incr i} {
	
        set tcp($i) [new Agent/TCP]
        set sink($i) [new Agent/TCPSink]
        $ns attach-agent $s($i) $tcp($i)
        $ns attach-agent $d($i) $sink($i)
        $ns connect $tcp($i) $sink($i)
	
        set ftp($i) [new Application/FTP]
        $ftp($i) attach-agent $tcp($i)
        $ftp($i) set type_ FTP
}



set rng [new RNG]
$rng seed 1

set RVstart [new RandomVariable/Uniform]
$RVstart set min_ 0
$RVstart set max_ 1
$RVstart use-rng $rng

#由亂數產生器去決定每一條flow的起始時間(在0到1秒之內)
#每條flow傳輸5秒
#並在指定的時間,讓ftp開始傳輸和結束
for {set i 1} { $i <= $nflow } { incr i } {
	
	set startT($i) [expr [$RVstart value]]
	puts "startT($i) $startT($i) sec"

	set endT($i) [expr ($startT($i)+5)]
	puts "endT($i) $endT($i) sec"

	$ns at $startT($i) "$ftp($i) start"
	$ns at $endT($i) "$ftp($i) stop"
}

proc finish {} {
    global ns nd
    
    close $nd
    $ns flush-trace

    exit 0
}

#在第7秒時去呼叫finish來結束模擬
$ns at 7.0 "finish"

#執行模擬
$ns run
