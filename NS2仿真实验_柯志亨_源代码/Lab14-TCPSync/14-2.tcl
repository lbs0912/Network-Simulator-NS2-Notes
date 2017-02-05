#create a simulator
set ns [new Simulator]

# open a TRACE file
set nd [open out.tr w]
$ns trace-all $nd

# open a cwnd file
set f0 [open cwnd0.tr w]
set f1 [open cwnd1.tr w]
set f2 [open cwnd2.tr w]

# define a finish process
proc finish {} {
	global ns nd f0 f1 f2
	# puts "ACK number:[$tcp0 set ack_]"

	$ns flush-trace

	close $nd
	close $f0
	close $f1
	close $f2

	exit 0
}

# define a record proc 每个0.1秒就去记录当时的cwnd
proc record {tcp_} {
	global ns f0 f1 f2
	upvar $tcp_ tcp

	set now [$ns now]
	puts $f0 "$now [$tcp(0) set cwnd_]"
	puts $f1 "$now [$tcp(1) set cwnd_]"
	puts $f2 "$now [$tcp(2) set cwnd_]"
	$ns at [expr $now + 0.01] "record tcp"
}

#create 5 nodes
set r0 [$ns node]
set r1 [$ns node]
$ns duplex-link $r1 $r0 1.5Mb  10ms DropTail
$ns queue-limit $r0 $r1 64


for {set i 0} {$i < 3} {incr i} {
	set s($i) [$ns node]
	set d($i) [$ns node]

	$ns duplex-link $s($i) $r0 10Mb 1ms DropTail
	$ns duplex-link $d($i) $r1 10Mb 1ms DropTail

	set tcp($i) [new Agent/TCP/Reno]
	set tcpsink($i) [new Agent/TCPSink]
	$ns attach-agent $s($i) $tcp($i)
	$ns attach-agent $d($i) $tcpsink($i)
	$ns connect $tcp($i) $tcpsink($i)
	$tcp($i) set fid_ $i
	$tcpsink($i) set fid_ $i

	$tcp($i) set window_ 128
	$tcp($i) set packetSize_ 536

	set ftp($i) [new Application/FTP]
	$ftp($i) attach-agent $tcp($i)


	set rng [new RNG]
	$rng seed 0

	set u [new RandomVariable/Uniform]
	$u use-rng $rng
	$u set min_ 0.0
	$u set max_ 10.0
	set random [expr [$u value]]


	$ns at $random "$ftp($i) start"
	$ns at 40.0 "$ftp($i) stop"

} 




$ns at 0.0 "record tcp"
$ns at 40.0 "finish"


$ns run















