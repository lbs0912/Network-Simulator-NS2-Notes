# Creating New Simulator
set ns [new Simulator -multicast on]
set group0 [Node allocaddr]
# Setting up the traces
set f [open out.tr w]
$ns trace-all $f
proc finish {} { 
	global ns nf f
	$ns flush-trace
	puts "Simulation completed."
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


#
#Setup Connections
#

$ns duplex-link $n0 $n1 2Mb 10ms DropTail



#
#Set up Transportation Level Connections
#

set udp0 [new Agent/UDP]
    $udp0 set dst_addr_ $group0
$ns attach-agent $n0 $udp0

set lossMonitor0 [new Agent/LossMonitor]
$ns attach-agent $n1 $lossMonitor0



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


$ns at 0 "$n1 join-group $lossMonitor0 $group0"

$ns at 10 "$n1 leave-group $lossMonitor0 $group0"
$ns at 0 "$Exponential0 start"
$ns at 10 "$Exponential0 stop"
$ns at 10.0 "finish"
$ns run
