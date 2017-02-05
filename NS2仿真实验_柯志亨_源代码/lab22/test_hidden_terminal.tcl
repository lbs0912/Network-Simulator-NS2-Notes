set val(chan)           Channel/WirelessChannel   
set val(prop)           Propagation/TwoRayGround   
set val(netif)          Phy/WirelessPhy            
set val(mac)            Mac/802_11                
set val(ifq)            Queue/DropTail/PriQueue    
set val(ll)             LL                         
set val(ant)            Antenna/OmniAntenna       
set val(ifqlen)         100                         
set val(rp) 		DSDV

set ns [new Simulator]

#Mac/802_11 set RTSThreshold_    0
Mac/802_11 set RTSThreshold_    3000

Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5 
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 2.81838e-9
Phy/WirelessPhy set RXThresh_ 6.88081e-9
Phy/WirelessPhy set bandwidth_ 2e6
Phy/WirelessPhy set Pt_ 0.281838
Phy/WirelessPhy set freq_ 9.14e+6
Phy/WirelessPhy set L_ 1.0 

set f [open test.tr w]
$ns trace-all $f
$ns eventtrace-all
set nf [open test.nam w]
$ns namtrace-all-wireless $nf 500 500

set topo       [new Topography]
$topo load_flatgrid 500 500
create-god 3
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

for {set i 0} {$i < 3} {incr i} {
        set node_($i) [$ns node]
        $node_($i) random-motion 0
}

$node_(0) set X_ 30.0
$node_(0) set Y_ 30.0
$node_(0) set Z_ 0.0
$node_(1) set X_ 130.0
$node_(1) set Y_ 30.0
$node_(1) set Z_ 0.0
$node_(2) set X_ 230.0
$node_(2) set Y_ 30.0
$node_(2) set Z_ 0.0

set udp [new Agent/mUDP]
$udp set_filename sd1
$ns attach-agent $node_(0) $udp
set null [new Agent/mUdpSink]
$null set_filename rd1
$ns attach-agent $node_(1) $null
$ns connect $udp $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1Mb
$cbr set random_ false
$ns at  1.5 "$cbr start"
$ns at 15.0 "$cbr stop"

set udp2 [new Agent/mUDP]
$udp2 set_filename sd2
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
$ns at  2.0 "$cbr2 start"
$ns at 15.0 "$cbr2 stop"

for {set i 0} {$i < 3} {incr i} {
        $ns initial_node_pos $node_($i) 30
        $ns at 20.0 "$node_($i) reset";
}

$ns at 20.0 "finish"
$ns at 20.1 "puts \"NS EXITING...\"; $ns halt"

proc finish {} {
        global ns f nf val
        $ns flush-trace
        close $f
        close $nf
}

$ns run
