# Creating New Simulator
set ns [new Simulator]

# Setting up the traces
set f [open out.tr w]
set nf [open out.nam w]
$ns namtrace-all $nf
$ns trace-all $f
proc finish {} { 
	global ns nf f
	$ns flush-trace
	puts "Simulation completed."
	close $nf
	close $f
	exit 0
}


#
#Create Nodes
#

set n0 [$ns node]
      puts "n0: [$n0 id]"
set n1 [$ns node]
      puts "n1: [$n1 id]"
set n2 [$ns node]
      puts "n2: [$n2 id]"
set n3 [$ns node]
      puts "n3: [$n3 id]"


#
#Setup Connections
#

$ns duplex-link $n0 $n2 2Mb 10ms DropTail

$ns duplex-link $n1 $n2 2Mb 10ms DropTail

$ns duplex-link $n2 $n3 1.7Mb 10ms DropTail



#
#Set up Transportation Level Connections
#

set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0

set sink0 [new Agent/TCPSink]
$ns attach-agent $n3 $sink0

set udp0 [new Agent/UDP]
$ns attach-agent $n1 $udp0

set null0 [new Agent/Null]
$ns attach-agent $n3 $null0



#
#Setup traffic sources
#

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

set cbr0 [new Application/Traffic/CBR]
    $cbr0 set rate_ 1Mb
    $cbr0 set packetSize_ 1000
$cbr0 attach-agent $udp0

$ns connect $tcp0 $sink0
$tcp0 set fid_ 0
$ns connect $udp0 $null0
$udp0 set fid_ 1

#
#Start up the sources
#

$ns at 0.1 "$cbr0 start"
$ns at 1 "$ftp0 start"
$ns at 4 "$ftp0 stop"
$ns at 4.5 "$cbr0 stop"
$ns at 5.0 "finish"
$ns run