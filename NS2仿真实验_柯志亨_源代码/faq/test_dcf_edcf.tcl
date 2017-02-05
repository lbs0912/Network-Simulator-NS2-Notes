set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(rp) 		DSDV
 
set ns [new Simulator]

Mac/802_11 set dataRate_  2Mb
Mac/802_11 set basicRate_ 1Mb

Mac/802_11 set RTSThreshold_    3000

set f [open test.tr w]
$ns trace-all $f
$ns eventtrace-all
set nf [open test.nam w]
$ns namtrace-all-wireless $nf 500 500

# set up topography object
set topo       [new Topography]

$topo load_flatgrid 500 500

# Create God
create-god 3

# create channel 
set chan [new $val(chan)]

$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -channel $chan \
                -topoInstance $topo \
                -agentTrace ON \
                -routerTrace OFF \
                -macTrace ON \
                -movementTrace OFF 
 

for {set i 0} {$i < 2} {incr i} {
        set node_($i) [$ns node]
        $node_($i) random-motion 0
}

set val(mac1)            Mac/802_11e                 ;# MAC type
set val(ifq1)            Queue/DTail/PriQ            ;# interface queue type

Mac/802_11e set dataRate_   2Mb
Mac/802_11e set basicRate_  1Mb 

$ns node-config -macType $val(mac1)
$ns node-config -ifqType $val(ifq1)

set node_(2) [$ns node]
$node_(2) random-motion 0

$node_(0) set X_ 30.0
$node_(0) set Y_ 30.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 50.0
$node_(1) set Y_ 30.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 100.0
$node_(2) set Y_ 30.0
$node_(2) set Z_ 0.0

set udp [new Agent/mUDP]
#set the sender trace file name to sd1
$udp set_filename sd1
$ns attach-agent $node_(0) $udp
set null [new Agent/mUdpSink]
#set the receiver filename to rd1
$null set_filename rd1
$ns attach-agent $node_(1) $null
$ns connect $udp $null 

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1Mb
$cbr set random_ false
$ns at 1.5 "$cbr start"
$ns at 15.0 "$cbr stop"

set udp2 [new Agent/mUDP]
$udp2 set_filename sd2
$udp2 set prio_ 0
$ns attach-agent $node_(2) $udp2
set null2 [new Agent/mUdpSink]
$null2 set_filename rd2
$ns attach-agent $node_(1) $null2
$ns connect $udp2 $null2
 
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set type_ CBR
$cbr2 set packet_size_ 1000
$cbr2 set rate_ 1Mb
$cbr2 set random_ false

$ns at 2.0 "$cbr2 start"
$ns at 15.0 "$cbr2 stop"

for {set i 0} {$i < 3} {incr i} {
        $ns initial_node_pos $node_($i) 30
        $ns at 20.0 "$node_($i) reset";
}

$ns at 20.0 "finish"
$ns at 20.1 "puts \"NS EXITING...\"; $ns halt"

#INSERT ANNOTATIONS HERE
proc finish {} {
        global ns f nf val
        $ns flush-trace
        close $f
        close $nf
}

puts "Starting Simulation..."
$ns run
