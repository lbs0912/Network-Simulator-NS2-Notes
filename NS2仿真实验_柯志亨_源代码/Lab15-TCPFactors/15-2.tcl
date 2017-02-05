
if {$argc != 3} {
	puts "Usage: ns 15-2.tcl TCPVersion tcpTick1 tcpTick2"
	exit
}

set par1 [lindex $argv 0]
set par2 [lindex $argv 1]
set par3 [lindex $argv 2]


#create a simulator
set ns [new Simulator]

# open a TRACE file
set nd [open out.tr w]
$ns trace-all $nd

# open a cwnd file
set f0 [open cwnd0-tcpTick-$par1.tr w]
set f1 [open cwnd1-tcpTick-$par1.tr w]


# define a finish process
proc finish {} {
	global ns nd f0 f1  tcp0 tcp1
	# puts "ACK number:[$tcp0 set ack_]"

	# 显示最后的平均吞吐量
	puts [format "tcp0:\t%.1f kbps" [expr [$tcp0 set ack_]*([$tcp0 set packetSize_])*8/1000.0/40]]
    puts [format "tcp1:\t%.1f kbps" [expr [$tcp1 set ack_]*([$tcp1 set packetSize_])*8/1000.0/40]]
	
	$ns flush-trace

	close $nd
	close $f0
	close $f1
	

	exit 0
}

# define a record proc 每个0.1秒就去记录当时的cwnd
proc record {} {
	global ns f0 f1 tcp0 tcp1
	
	set now [$ns now]
	puts $f0 "$now [$tcp0 set cwnd_]"
	puts $f1 "$now [$tcp1 set cwnd_]"
	
	$ns at [expr $now + 0.01] "record"
}

#create 5 nodes
set s0 [$ns node]
set s1 [$ns node]
set d0 [$ns node]
set d1 [$ns node]
set r0 [$ns node]
set r1 [$ns node]
set r2 [$ns node]

$ns duplex-link $s0 $r0 10Mb  1ms DropTail
$ns duplex-link $s1 $r0 10Mb  1ms DropTail
$ns duplex-link $r0 $r1 1.5Mb  40ms DropTail
$ns duplex-link $r1 $r2 1.5Mb  40ms DropTail
$ns duplex-link $r2 $d1 10Mb  1ms DropTail
$ns duplex-link $r2 $d0 10Mb  1ms DropTail


# 设置队列长度为32个封包大小
set buffer_size 32
$ns queue-limit $r0 $r1 $buffer_size


# establish FTP0 Application
if {$par1 == "Tahoe"} {
	puts "Tahoe"
	set tcp0 [new Agent/TCP]
	set tcp0sink [new Agent/TCPSink]
} elseif {$par1 == "Reno"} {
	puts "Reno"
	set tcp0 [new Agent/TCP/Reno]
	set tcp0sink [new Agent/TCPSink]
} elseif {$par1 == "Newreno"} {
	puts "Newreno"
	set tcp0 [new Agent/TCP/Newreno]
	set tcp0sink [new Agent/TCPSink]
} elseif {$par1 == "Sack"} {
	puts "Sack"
	set tcp0 [new Agent/TCP/Sack1]
	set tcp0sink [new Agent/TCPSink]
} else {
	puts "Vegas"
	set tcp0 [new Agent/TCP/Vegas]
	$tcp0 set v_alpha_ 1
	$tcp0 set v_beta_ 3
	set tcp0sink [new Agent/TCPSink]
}


$tcp0 set packetSize_ 1024
$tcp0 set window_ 128
$tcp0 set tcpTick_ $par2
$tcp0 set fid_ 0
$ns attach-agent $s0 $tcp0

$tcp0sink set fid_ 0
$ns attach-agent $d0 $tcp0sink

$ns connect $tcp0sink $tcp0

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0



# establish FTP1 Application
if {$par1 == "Tahoe"} {
	set tcp1 [new Agent/TCP]
	set tcp1sink [new Agent/TCPSink]
} elseif {$par1 == "Reno"} {
	set tcp1 [new Agent/TCP/Reno]
	set tcp1sink [new Agent/TCPSink]
} elseif {$par1 == "Newreno"} {
	set tcp1 [new Agent/TCP/Newreno]
	set tcp1sink [new Agent/TCPSink]
} elseif {$par1 == "Sack"} {
	set tcp1 [new Agent/TCP/Sack1]
	set tcp1sink [new Agent/TCPSink]
} else {
	set tcp1 [new Agent/TCP/Vegas]
	$tcp1 set v_alpha_ 1
	$tcp1 set v_beta_ 3
	set tcp1sink [new Agent/TCPSink]
}

$tcp1 set packetSize_ 1024
$tcp1 set window_ 128
$tcp1 set tcpTick_ $par3
$tcp1 set fid_ 1
$ns attach-agent $s1 $tcp1

$tcp0sink set fid_ 1
$ns attach-agent $d1 $tcp1sink

$ns connect $tcp1sink $tcp1

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1



$ns at 0.0 "$ftp0 start"
$ns at 0.0 "$ftp1 start"


$ns at 40.0 "$ftp0 stop"
$ns at 40.0 "$ftp1 stop"

$ns at 0.0 "record"
$ns at 40.0 "finish"


$ns run















