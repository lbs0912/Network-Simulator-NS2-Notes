#create a simulator
set ns [new Simulator]

# open a TRACE file
set nd [open out-13-2.tr w]
$ns trace-all $nd

# open a cwnd file
set f0 [open cwnd-vegas.tr w]
set f1 [open cwnd-reno.tr w]

# define a finish process
proc finish {} {
	global ns nd f0 tcp0 f1 tcp1
	# puts "ACK number:[$tcp0 set ack_]"


	# 显示最后的平均吞吐量
	puts [format "Vegas-Throughput: %.1f Kbps" \
			[expr [$tcp0 set ack_]*([$tcp0 set packetSize_])*8/1000.0/10]]
	puts [format "Reno-Throughput: %.1f Kbps" \
			[expr [$tcp1 set ack_]*([$tcp1 set packetSize_])*8/1000.0/10]]

	$ns flush-trace

	close $nd
	close $f0
	close $f1

	exit 0
}

# define a record proc 每个0.1秒就去记录当时的cwnd
proc record {} {
	global ns tcp0 f0 tcp1 f1
	set now [$ns now]
	puts $f0 "$now [$tcp0 set cwnd_]"
	puts $f1 "$now [$tcp1 set cwnd_]"
	$ns at [expr $now + 0.01] "record"
}

#create 5 nodes
set r0 [$ns node]
set r1 [$ns node]
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

# link nodes together
$ns duplex-link $n0 $r0 10Mb 1ms DropTail
$ns duplex-link $r0 $n2 10Mb 1ms DropTail
$ns duplex-link $r1 $r0 1Mb  20ms DropTail
$ns duplex-link $r1 $n1 10Mb 1ms DropTail
$ns duplex-link $r1 $n3 10Mb 1ms DropTail


# 设置队列长度是15个封包大小
set buffer_size 15
$ns queue-limit $r0 $r1 $buffer_size

# establish TCP Vegas Vegas' FTP connect
set tcp0 [new Agent/TCP/Vegas]
$tcp0 set v_alpha_ 1
$tcp0 set v_beta_ 3
$tcp0 set window_ 24
$ns attach-agent $n0 $tcp0

set tcp0sink [new Agent/TCPSink]
$ns attach-agent $n1 $tcp0sink
$ns connect $tcp0sink $tcp0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

# establish TCP Reno' FTP connect
set tcp1 [new Agent/TCP/Reno]
$tcp1 set window_ 24
$ns attach-agent $n2 $tcp1

set tcp1sink [new Agent/TCPSink]
$ns attach-agent $n3 $tcp1sink
$ns connect $tcp1sink $tcp1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1






$ns at 0.0 "$ftp0 start"
$ns at 10.0 "$ftp0 stop"

$ns at 0.0 "$ftp1 start"
$ns at 10.0 "$ftp1 stop"

$ns at 0.0 "record"
$ns at 10.0 "finish"


$ns run















