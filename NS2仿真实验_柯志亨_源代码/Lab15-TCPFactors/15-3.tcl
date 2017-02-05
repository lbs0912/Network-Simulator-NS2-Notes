
if {$argc != 1} {
	puts "Usage: ns 15-3.tcl Bandwidth(Mbps)"
	exit
}

set bandwidth [lindex $argv 0]

# 设置每秒可以处理的封包数（含TCP/IP Header）
set mu [expr $bandwidth*1000000/(8*552)]

# Round Trip Time
set tau [expr (1+18+1)*2*0.001]
set beta .64

# 设置buffer size为bandwidth-delay product的beta倍
# 以去观察频宽的使用频率与sstresh之间的关系
set B [expr $beta*($mu*$tau+1)+0.5]

puts "Buffer Size: $B"

# calculate bandwidth-delay product
puts "bandwidth-delay product = [expr $mu*$tau+1]"

#create a simulator
set ns [new Simulator]

# open a TRACE file
set nd [open out.tr w]
$ns trace-all $nd

# open a cwnd file
set f1 [open sq-sstresh.tr w]
set f2 [open throughput-ssthresh.tr w]
set f3 [open cwnd-sstresh.tr w]

# define a finish process
proc finish {} {
	global ns nd f2 f1  tcp0 sink0 bandwidth
	# puts "ACK number:[$tcp0 set ack_]"

	$ns flush-trace

	close $nd
	close $f2
	close $f1

	set now [$ns now]
	set ack [$tcp0 set ack_]
	set size [$tcp0 set packetSize_]
	set throughput [expr $ack*($size)*8/$now/1000000.0]
	set ut [expr ($throughput/$bandwidth)*100.0]

	# 显示最后的平均吞吐量
	puts [format "throughput:\t%.2f Mbps" $throughput]
    puts [format "utilization:\t%.1f" $ut]


	exit 0
}

# define a record proc 每个0.1秒就去记录当时的cwnd
proc record {} {
	global ns f3 f2 f1 tcp0 sink0
	
	set now [$ns now]
	set time 0.05

	set seq [$tcp0 set seqno_]
	set cwnd [$tcp0 set cwnd_]
	set bw [$sink0 set bytes_]

	puts $f1 "$now $seq"
	puts $f1 "$now [expr $bw*8/$now/1000]"
	puts $f3 "$now $cwnd"

	$ns at [expr $now + $time] "record"
}

#create 5 nodes
set r0 [$ns node]
set r1 [$ns node]
set n0 [$ns node]
set n1 [$ns node]



set bd $bandwidth+Mb
$ns duplex-link $n0 $r0 100Mb  1ms DropTail
$ns duplex-link $r1 $r0 $bd  18ms DropTail
$ns duplex-link $n1 $r1 100Mb  1ms DropTail

$ns queue-limit $r0 $r1 $B


# establish FTP Application
set tcp0 [new Agent/TCP/Reno]
set sink0 [new Agent/TCPSink]
$tcp0 set packetSize_ 512
$tcp0 set window_ 64
$ns attach-agent $n0 $tcp0


$ns attach-agent $n1 $sink0

$ns connect $sink0 $tcp0

set ftp [new Application/FTP]
$ftp attach-agent $tcp0




$ns at 0.0 "$ftp start"
$ns at 30.0 "$ftp stop"



$ns at 0.05 "record"
$ns at 30.0 "finish"


$ns run















