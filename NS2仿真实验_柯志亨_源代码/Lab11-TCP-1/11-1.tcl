#create a simulator
set ns [new Simulator]

#若用户设定了使用距离相量(distance vector)算法的动态路由方式
#则设定路由的方式为Dv
if {$argc != 1} {
	puts "Usage: ns 11-1.tcl TCPVersion"
	puts "Example: ns 11-1.tcl Tahoe or ns 11-1-.tcl Reno"
	exit
}

set par1 [lindex $argv 0]


# open a TRACE file
set nd [open out-$par1.tr w]
$ns trace-all $nd

# open a cwnd file
set f0 [open cwnd-$par1.tr w]

# define a finish process
proc finish {} {
	global ns nd f0 tcp

	# 显示最后的平均吞吐量
	puts [format "Average Throughput: %.1f Kbps" \
			[expr [$tcp set ack_]*([$tcp set packetSize_])*8/1000.0/10]]
	$ns flush-trace
	close $nd
	close $f0

	exit 0
}

# define a record proc
proc record {} {
	global ns tcp f0
	set now [$ns now]
	puts $f0 "$now [$tcp set cwnd_]"
	$ns at [expr $now + 0.01] "record"
}

#create 5 nodes
set n0 [$ns node]
set r0 [$ns node]
set n1 [$ns node]
set r1 [$ns node]

# link nodes together
$ns duplex-link $n0 $r0 10Mb 1ms DropTail
$ns duplex-link $r0 $r1 1Mb 4ms DropTail
$ns duplex-link $r1 $n1 10Mb 1ms DropTail


# 设置队列长度是18个封包大小
set queue 18
$ns queue-limit $r0 $r1 $queue

# select TCP Version
if {$par1 == "Tahoe"} {
	set tcp [new Agent/TCP]
} else {
	set tcp [new Agent/TCP/Reno]
}

$ns attach-agent $n0 $tcp

set tcpsink [new Agent/TCPSink]
$ns attach-agent $n1 $tcpsink
$ns connect $tcp $tcpsink


# set FTP link
set ftp [new Application/FTP]
$ftp attach-agent $tcp


$ns at 0.0 "$ftp start"
$ns at 10.0 "$ftp stop"

$ns at 0.0 "record"
$ns at 10.0 "finish"

$ns run















