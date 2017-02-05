if {$argc!=3} {
	puts "Usage: ns lab15_2.tcl TcpVersion tcpTick1 tcpTick2 "
	exit
}

set par1 [lindex $argv 0]
set par2 [lindex $argv 1]
set par3 [lindex $argv 2]

# 產生一個模擬的物件
set ns [new Simulator]

#開啟記錄檔，用來記錄封包傳送的過程
set nd [open out.tr w]
$ns trace-all $nd

#開啟兩個檔案用來記錄FTP0和FTP1的cwnd變化情況
set f0 [open cwnd0-$par1-tcpTick.tr w]
set f1 [open cwnd1-$par1-tcpTick.tr w]

#定義一個結束的程序
proc finish {} {
        global ns nd f0 f1 tcp0 tcp1
        
        #顯示最後的平均吞吐量
        puts [format "tcp0:\t%.1f Kbps" \
         [expr [$tcp0 set ack_]*([$tcp0 set packetSize_])*8/1000.0/40]]
        puts [format "tcp1:\t%.1f Kbps" \
         [expr [$tcp1 set ack_]*([$tcp1 set packetSize_])*8/1000.0/40]]

        $ns flush-trace
        
	#關閉檔案
        close $nd
        close $f0
        close $f1

        exit 0
}

#定義一個記錄的程序
#每格0.01秒就去記錄當時的tcp0和tcp1的cwnd
proc record {} {
	global ns tcp0 f0 tcp1 f1
	
	set now [$ns now]
	puts $f0 "$now [$tcp0 set cwnd_]"
	puts $f1 "$now [$tcp1 set cwnd_]"
	$ns at [expr $now+0.01] "record"
}

#建立節點
set s0 [$ns node]
set s1 [$ns node]
set d0 [$ns node]
set d1 [$ns node]
set r0 [$ns node]
set r1 [$ns node]
set r2 [$ns node]

#建立鏈路
$ns duplex-link $s0 $r0 10Mb 1ms DropTail
$ns duplex-link $s1 $r0 10Mb 1ms DropTail
$ns duplex-link $r0 $r1 1.5Mb 40ms DropTail
$ns duplex-link $r1 $r2 1.5Mb 40ms DropTail
$ns duplex-link $r2 $d1 10Mb 1ms DropTail
$ns duplex-link $r2 $d0 10Mb 1ms DropTail

#設定佇列長度為32個封包大小
set buffer_size 32
$ns queue-limit $r0 $r1 $buffer_size

#建立FTP0應用程式(RTT較短)

if {$par1=="Tahoe"} {
	puts "Tahoe"
	set tcp0 [new Agent/TCP]
	set tcpsink0 [new Agent/TCPSink]
} elseif {$par1=="Reno"} {
	puts "Reno"
	set tcp0 [new Agent/TCP/Reno]
	set tcpsink0 [new Agent/TCPSink]
} elseif {$par1=="Newreno"} {
	puts "Newreno"
	set tcp0 [new Agent/TCP/Newreno]
	set tcpsink0 [new Agent/TCPSink]
} elseif {$par1=="Sack"} {
	puts "Sack"
	set tcp0 [new Agent/TCP/Sack1]
	set tcpsink0 [new Agent/TCPSink/Sack1]
} else {
	set tcp0 [new Agent/TCP/Vegas]
	puts "Vegas"
	$tcp0 set v_alpha_ 1
	$tcp0 set v_beta_ 3
	set tcpsink0 [new Agent/TCPSink]
}	
$tcp0 set packetSize_ 1024
$tcp0 set window_ 128

#例如tcp0 set tcpTick_ 0.5 這個0.5所代表的是500ms
$tcp0 set tcpTick_ $par2
$tcp0 set fid_ 0
$ns attach-agent $s0 $tcp0

$tcpsink0 set fid_ 0
$ns attach-agent $d0 $tcpsink0

$ns connect $tcp0 $tcpsink0

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

#建立FTP1應用程式(RTT較長)
if {$par1=="Tahoe"} {
	set tcp1 [new Agent/TCP]
	set tcpsink1 [new Agent/TCPSink]
} elseif {$par1=="Reno"} {
	set tcp1 [new Agent/TCP/Reno]
	set tcpsink1 [new Agent/TCPSink]
} elseif {$par1=="Newreno"} {
	set tcp1 [new Agent/TCP/Newreno]
	set tcpsink1 [new Agent/TCPSink]
} elseif {$par1=="Sack"} {
	set tcp1 [new Agent/TCP/Sack1]
	set tcpsink1 [new Agent/TCPSink/Sack1]
} else {
	set tcp1 [new Agent/TCP/Vegas]
	$tcp1 set v_alpha_ 1
	$tcp1 set v_beta_ 3
	set tcpsink1 [new Agent/TCPSink]
}	
$tcp1 set packetSize_ 1024
$tcp1 set window_ 128
$tcp1 set tcpTick_ $par3
$tcp1 set fid_ 1
$ns attach-agent $s1 $tcp1

$tcpsink1 set fid_ 1
$ns attach-agent $d1 $tcpsink1

$ns connect $tcp1 $tcpsink1

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

#在0.0秒時,FTP0和FTP1開始傳送
$ns at 0.0 "$ftp0 start"
$ns at 0.0 "$ftp1 start"

#在40.0秒時,FTP0和FTP1結束傳送
$ns at 40.0 "$ftp0 stop"
$ns at 40.0 "$ftp1 stop"

#在0.0秒時去呼叫record來記錄FTP0和FTP1的cwnd變化情況
$ns at  0.0 "record"

#在第40.0秒時去呼叫finish來結束模擬
$ns at 40.0 "finish"

#執行模擬
$ns run
