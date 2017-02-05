set val(chan)          Channel/WirelessChannel     ;# channel type
set val(prop)          Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)         Phy/WirelessPhy            ;# network interface type
set val(mac)           Mac/802_11                ;# MAC type
set val(ifq)           Queue/DropTail/PriQueue     ;# interface queue type
set val(ll)            LL                       ;# link layer type
set val(ant)           Antenna/OmniAntenna       ;# antenna model
set val(ifqlen)        100                       ;# max packet in ifq
set val(rp)            DSDV

# disable RTS/CTS
Mac/802_11 set RTSThreshold_    3000

set ns [new Simulator]
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
#天線高度
Antenna/OmniAntenna set Z_ 1.5 
#天線增益
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

#按照threshold所設定
Phy/WirelessPhy set RXThresh_ 3.652e-10
Phy/WirelessPhy set bandwidth_ 2e6
Phy/WirelessPhy set Pt_ 0.28183815
Phy/WirelessPhy set freq_ 914e+6
Phy/WirelessPhy set L_ 1.0  

set f [open test.tr w]
$ns trace-all $f
$ns eventtrace-all
set nf [open test.nam w]
$ns namtrace-all-wireless $nf 500 500

# set up topography object
set topo       [new Topography]

$topo load_flatgrid 500 500

# Create God
create-god 2

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

#設定node_(0)和node_(1)距離為250公尺
$node_(0) set X_ 30.0
$node_(0) set Y_ 30.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 280.0
$node_(1) set Y_ 30.0
$node_(1) set Z_ 0.0

set udp [new Agent/mUDP]
#set the sender trace file name to sd
$udp set_filename sd
$ns attach-agent $node_(0) $udp

set null [new Agent/mUdpSink]
#set the receiver filename to rd
$null set_filename rd
$ns attach-agent $node_(1) $null
$ns connect $udp $null

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 100kb
$cbr set random_ false

$ns at  5.0 "$cbr start"
$ns at 15.0 "$cbr stop"

for {set i 0} {$i < 2} {incr i} {
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
