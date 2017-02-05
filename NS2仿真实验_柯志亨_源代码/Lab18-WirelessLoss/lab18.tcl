
set opt(stop) 250


set opt(num_FA) 1


proc getopt {argc argv} {
	global opt
        lappend optlist nn
        for {set i 0} {$i < $argc} {incr i} {
		set opt($i) [lindex $argv $i]
	}
}

getopt $argc $argv

set pGG $opt(0)
set pBB $opt(1)
set pG $opt(2)
set pB $opt(3)
set loss_model  $opt(4)

set comm_type  $opt(5)

set ns_ [new Simulator]


Mac/802_11 set LongRetryLimit_    4


$ns_ node-config -addressType hierarchical


AddrParams set domain_num_ 2


lappend cluster_num 1 1
AddrParams set cluster_num_ $cluster_num


lappend eilastlevel 1 2
AddrParams set nodes_num_ $eilastlevel


set tracefd [open test.tr w]
$ns_ trace-all $tracefd

set opt(nnn) 1


set topo [new Topography]
$topo load_flatgrid 100 100


set god_ [create-god [expr $opt(nnn)+$opt(num_FA)]]


set W(0) [$ns_ node 0.0.0]

# create channel 
set chan_ [new Channel/WirelessChannel]


$ns_ node-config -mobileIP ON \
	         -adhocRouting NOAH \
             	 -llType LL \
               	 -macType Mac/802_11 \
                 -ifqType Queue/DropTail/PriQueue \
                 -ifqLen  2000 \
                 -antType Antenna/OmniAntenna \
	         -propType Propagation/TwoRayGround \
	         -phyType Phy/WirelessPhy \
                 -channel $chan_ \
	         -topoInstance $topo \
                 -wiredRouting ON\
	         -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON


set HA [$ns_ node 1.0.0]

$ns_ node-config -wiredRouting OFF


set MH(0) [$ns_ node 1.0.1]


set MHnetif_(0) [$MH(0) set netif_(0)]


$MHnetif_(0) set-error-level $pGG $pBB $pG $pB $loss_model


[$MH(0)  set regagent_] set home_agent_ [AddrParams addr2id [$HA node-addr]]


$HA set X_ 100.0
$HA set Y_ 100.0
$HA set Z_ 0.0


$MH(0) set X_ 80.0
$MH(0) set Y_ 80.0
$MH(0) set Z_ 0.0


$ns_ duplex-link $W(0) $HA 10Mb 10ms DropTail

$ns_ at $opt(stop).1 "$MH(0) reset";
$ns_ at $opt(stop).0001 "$W(0) reset"


set udp0 [new Agent/mUDP]
$udp0 set_filename sd
$udp0 set packetSize_ 1000
$ns_ attach-agent $W(0) $udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set rate_ 500kb
$cbr0 set packetSize_ 1000
set null0 [new Agent/mUdpSink]
$null0 set_filename rd
$MH(0) attach $null0 3


set forwarder_ [$HA  set forwarder_]
puts [$forwarder_ port]
$ns_ connect $udp0 $forwarder_
$forwarder_ dst-addr [AddrParams addr2id [$MH(0) node-addr]]
$forwarder_ comm-type $comm_type


$ns_ at 2.4 "$cbr0 start"


$ns_ at 200.0 "$cbr0 stop"

$ns_ at $opt(stop).0002 "stop "
$ns_ at $opt(stop).0003  "$ns_  halt"


proc stop {} {
    global ns_ tracefd
    

    close $tracefd
}


$ns_ run
