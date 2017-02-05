
proc getopt {argc argv} {
	global opt
        lappend optlist nn
        for {set i 0} {$i < $argc} {incr i} {
		set opt($i) [lindex $argv $i]
	}
}
getopt $argc $argv

set opt(chan)   Channel/WirelessChannel   
set opt(prop)	Propagation/TwoRayGround
set opt(netif)	Phy/WirelessPhy


set opt(mac)	Mac/802_11
if { $opt(0)=="DSR"} {
  set opt(ifq)          CMUPriQueue 
} else {
  set opt(ifq)          Queue/DropTail/PriQueue    ;# interface queue type
}
set opt(ll)		LL
set opt(ant)        Antenna/OmniAntenna

set opt(x)		500   
set opt(y)		500   
set opt(ifqlen)		2000	      
set opt(seed)	0.0

set opt(tr)		trace1.tr    ;# trace file
set opt(adhocRouting)   $opt(0)

set opt(nn)             100      
    
set opt(cp)		"cbr_n100_m10_r10" 

set opt(sc)		"scen_100n_0p_10M_100t_500_500" 

set opt(stop)		100.0		

Mac/802_11 set CWMin_                 31
Mac/802_11 set CWMax_                 1023
Mac/802_11 set SlotTime_              0.000020  ;# 20us
Mac/802_11 set SIFS_                  0.000010  ;# 10us
Mac/802_11 set PreambleLength_        144       ;# 144 bit
Mac/802_11 set PreambleDataRate_      1.0e6     ;# 1Mbps
Mac/802_11 set PLCPHeaderLength_      48        ;# 48 bits
Mac/802_11 set PLCPDataRate_          1.0e6     ;# 1Mbps
Mac/802_11 set RTSThreshold_          3000      ;# bytes Disable RTS/CTS
Mac/802_11 set ShortRetryLimit_       7         ;# retrans_missions_
Mac/802_11 set LongRetryLimit_        4         ;# retrans_missions_

Mac/802_11 set dataRate_  2Mb			;# 802.11 data trans_mission rate
Mac/802_11 set basicRate_ 1Mb                   ;# 802.11 basic trans_mission rate 



set ns_		[new Simulator]

set wtopo	[new Topography]

set tracefd	[open $opt(tr) w]
$ns_ trace-all $tracefd
#$ns_ use-newtrace 


$wtopo load_flatgrid $opt(x) $opt(y)

set god_ [create-god $opt(nn)]

set chan_1_ [new $opt(chan)]

$ns_ node-config -adhocRouting $opt(adhocRouting) \
		 -llType $opt(ll) \
		 -macType $opt(mac) \
		 -ifqType $opt(ifq) \
		 -ifqLen $opt(ifqlen) \
		 -antType $opt(ant) \
		 -propType $opt(prop) \
		 -phyType $opt(netif) \
		 -channel $chan_1_ \
		 -topoInstance $wtopo \
		 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace OFF 
                 
for {set i 0} {$i < $opt(nn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0	
}


puts "Loading connection pattern..."

source $opt(cp)
 

puts "Loading scenario file..."

source $opt(sc)

for {set i 0} {$i < $opt(nn)} {incr i} {
   $ns_ initial_node_pos $node_($i) 20
}


for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop).1 "$node_($i) reset";
}

$ns_ at  $opt(stop).1 "puts \"ns_ EXITING...\" ; $ns_ halt"
puts "Starting Simulation..."
$ns_ run
