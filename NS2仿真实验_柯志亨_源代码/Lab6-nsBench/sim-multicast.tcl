# Creating New Simulator
set ns-multicast [new Simulator -multicast on]
set group0 [Node allocaddr]
# Setting up the traces
set f [open out-multicast.tr w]
set nf [open out-multicast.nam w]
$ns-multicast namtrace-all $nf
$ns-multicast trace-all $f
proc finish {} { 
	global ns-multicast nf f
	$ns-multicast flush-trace
	puts "Simulation completed."
	close $nf
	close $f
	exit 0
}


#
#Create Nodes
#

set n0 [$ns-multicast node]
      puts "n0: [$n0 id]"
set n1 [$ns-multicast node]
      puts "n1: [$n1 id]"


#
#Setup Connections
#

$ns-multicast duplex-link $n0 $n1 2Mb 10ms DropTail



#
#Set up Transportation Level Connections
#

set lossMonitor0 [new Agent/LossMonitor]
$ns-multicast attach-agent $n1 $lossMonitor0

set udp0 [new Agent/UDP]
    $udp0 set dst_addr_ $group0
$ns-multicast attach-agent $n0 $udp0



#
#Setup traffic sources
#

set Exponential0 [new Application/Traffic/Exponential]
$Exponential0 attach-agent $udp0


set mproto DM
set mrthandle [$ns mrtproto $mproto]


#
#Start up the sources
#

$ns-multicast at 0 "$Exponential0 start"
$ns-multicast at 10 "$Exponential0 stop"
$ns-multicast at 10.0 "finish"
$ns-multicast run