set ns [new Simulator]

#number of nodes
set num_mobile_nodes 3

# Parameter for wireless nodes
set opt(chan)           Channel/WirelessChannel    ;# channel type
set opt(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set opt(netif)          Phy/WirelessPhy            ;# network interface type
set opt(mac)            Mac/802_11                 ;# MAC type
set opt(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set opt(ifqlen)         50
set opt(ll)             LL                         ;# link layer type
set opt(ant)            Antenna/OmniAntenna        ;# antenna model
set opt(ifqlen)         50                        ;# max packet in ifq
set opt(adhocRouting)   DumbAgent                       ;# routing protocol
set opt(x)          670  ;# X dimension of the topography
set opt(y)          670          ;# Y dimension of the topography

#smallko add the following two lines
Mac/802_11 set dataRate_  1Mb
Mac/802_11 set basicRate_  1Mb

set ntr [open out_rc_3.tr w]
$ns trace-all $ntr

set chan    [new $opt(chan)]
set topo    [new Topography]

$topo load_flatgrid $opt(x) $opt(y)

# Create God
create-god $num_mobile_nodes

# config node
$ns node-config -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop)    \
                 -phyType $opt(netif) \
                 -channel $chan      \
                 -topoInstance $topo \
                 -wiredRouting OFF \
                 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace OFF    \
                 -movementTrace OFF

# creating mobile nodes
Mac/802_11 set RTSThreshold_ 3000
for {set i 0} {$i < $num_mobile_nodes} {incr i} {
    set wl_node_($i) [$ns node]         
    $wl_node_($i) random-motion 0               ;# disable random motion
    puts "wireless node $i created ..."
    $wl_node_($i) set X_ [expr $i * 10.0]
    $wl_node_($i) set Y_ [expr $i * 10.0]
    $wl_node_($i) set Z_ 0.0
}

set wl_ifq [$wl_node_(0) set ifq_(0)]
set queuechan [open qlen.tr w]
$wl_ifq trace curq_
$wl_ifq attach $queuechan

for {set i 0} {$i < $num_mobile_nodes} {incr i} {
    set src_udp_($i) [new Agent/UDP]
    $src_udp_($i) set class_ $i
    set dst_udp_($i) [new Agent/Null]
    $ns attach-agent $wl_node_($i) $src_udp_($i)
    $ns attach-agent $wl_node_([expr ($i+1)%($num_mobile_nodes)]) $dst_udp_($i)
    set app_($i) [new Application/Traffic/CBR]
    $app_($i) set packetSize_ 1025
    $app_($i) set interval_ 0.005
    $app_($i) attach-agent $src_udp_($i)
    $ns connect $src_udp_($i) $dst_udp_($i)
    $ns set fid_ $i
    $ns at $i "$app_($i) start"
}

# Define node initial position in nam
for {set i 0} {$i < $num_mobile_nodes} {incr i} {
    $ns initial_node_pos $wl_node_($i) 20
   }

# Tell nodes when the simulation ends
for {set i 0} {$i < $num_mobile_nodes } {incr i} {
    $ns at 10.0 "$wl_node_($i) reset";
}

for {set i 0} {$i < $num_mobile_nodes} {incr i} {
    $ns at 5.0 "$app_($i) stop"
}

$ns at 11.0 "puts \"NS EXITING...\" ; $ns halt"

proc stop {} {
    global ns ntr queuechan
    close $ntr
    close $queuechan
}

# run the simulation
$ns run