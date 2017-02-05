proc getopt {argc argv} {
	global opt
        lappend optlist nn
        for {set i 0} {$i < $argc} {incr i} {
		set opt($i) [lindex $argv $i]
	}
}

getopt $argc $argv

#opt(0)-> 0:dcf 1:edcf

#===================================
#     Simulation parameters setup
#===================================
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
if {$opt(0) > 0} {
  	set val(mac)            Mac/802_11e                ;# MAC type
	set val(ifq)            Queue/DTail/PriQ    	   ;# interface queue type
	Mac/802_11e set dataRate_  1Mb
	Mac/802_11e set basicRate_ 1Mb
} else {
  	set val(mac)            Mac/802_11                ;# MAC type
  	set val(ifq)            Queue/DropTail/PriQueue   ;# interface queue type
  	Mac/802_11 set dataRate_  1Mb
        Mac/802_11 set basicRate_ 1Mb 
}

set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                         ;# max packet in ifq
set val(nn)     3                          ;# number of mobilenodes
set val(rp)     DSDV                       ;# routing protocol
set val(x)      400                      ;# X dimension of topography
set val(y)      500                      ;# Y dimension of topography
set val(stop)   50.0                         ;# time of simulation end

#===================================
#        Initialization        
#===================================
#Create a ns simulator
set ns [new Simulator]

#Setup topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

#Open the NS trace file
set tracefile [open out.tr w]
$ns trace-all $tracefile

set chan [new $val(chan)];#Create wireless channel

#===================================
#     Mobile node parameter setup
#===================================
$ns node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -channel       $chan \
                -topoInstance  $topo \
                -agentTrace    OFF \
                -routerTrace   OFF \
                -macTrace      OFF \
                -movementTrace OFF

#===================================
#        Nodes Definition        
#===================================
#Create 3 nodes
set n0 [$ns node]
$n0 set X_ 200
$n0 set Y_ 400
$n0 set Z_ 0.0
$ns initial_node_pos $n0 20
set n1 [$ns node]
$n1 set X_ 300
$n1 set Y_ 400
$n1 set Z_ 0.0
$ns initial_node_pos $n1 20
set n2 [$ns node]
$n2 set X_ 200
$n2 set Y_ 350
$n2 set Z_ 0.0
$ns initial_node_pos $n2 20

#建立影像的傳輸
#===================================================

#設定把原本每一個畫面,切割成最大為多少size的封包
set max_fragmented_size 1024
set packetSize [expr $max_fragmented_size+28]

set src_udp1 [new Agent/my_UDP]
$src_udp1 set packetSize_ $packetSize
$src_udp1 set class_ 1
set dst_udp1 [new Agent/myEvalvid_Sink]
$ns attach-agent $n1 $dst_udp1
$ns attach-agent $n0 $src_udp1
$ns connect $src_udp1 $dst_udp1
$src_udp1 set_filename sd
$src_udp1 set class_ 1
$dst_udp1 set_filename rd

set original_file_name foreman_qcif.st
set trace_file_name video1.dat
set original_file_id [open $original_file_name r]
set trace_file_id [open $trace_file_name w]

set pre_time 0

while {[eof $original_file_id] == 0} {
    gets $original_file_id current_line
     
    scan $current_line "%d%s%d%d%f" no_ frametype_ length_ tmp1_ tmp2_
    set time [expr int(($tmp2_ - $pre_time)*1000000.0)]
          
    if { $frametype_ == "I" } {
  	set type_v 1
  	#設定prio_ 為1 (表示是video traffic)
  	set prio_p 1
    }	

    if { $frametype_ == "P" } {
  	set type_v 2
  	#設定prio_ 為1 (表示是video traffic)
  	set prio_p 1
    }	

    if { $frametype_ == "B" } {
  	set type_v 3
  	#設定prio_ 為1 (表示是video traffic)
  	set prio_p 1
    }	
    
    if { $frametype_ == "H" } {
  	set type_v 1
  	set prio_p 1
    }

    puts  $trace_file_id "$time $length_ $type_v $prio_p $max_fragmented_size"
    set pre_time $tmp2_
}

close $original_file_id
close $trace_file_id
set end_sim_time [expr $tmp2_+5.0]
puts "$end_sim_time"

set trace_file [new Tracefile]
$trace_file filename $trace_file_name
set video1 [new Application/Traffic/myEvalvid]
$video1 attach-agent $src_udp1
$video1 attach-tracefile $trace_file

#建立best effort的傳輸，作者使用TCP Reno版
#===================================================
set src_tcp1 [new Agent/TCP/Reno]
#設定其優先權
$src_tcp1 set class_ 2
$src_tcp1 set prio_ 2
set dst_tcp1 [new Agent/TCPSink]
$ns attach-agent $n2 $dst_tcp1
$ns attach-agent $n1 $src_tcp1
#建立FTP連線
set ftp1 [new Application/FTP]
$ftp1 attach-agent $src_tcp1
$ns connect $src_tcp1 $dst_tcp1

#建立background的傳輸
#===================================================
set src_udp2 [new Agent/UDP]
$src_udp2 set packetSize_  1500
$src_udp2 set class_ 3
$src_udp2 set prio_ 3
set dst_udp2 [new Agent/Null] 
$ns attach-agent $n2 $src_udp2
$ns attach-agent $n0 $dst_udp2
$ns connect $src_udp2 $dst_udp2
set traffic [new Application/Traffic/Exponential]
$traffic set	packetSize_	1500
$traffic set	burst_time_	0.8
$traffic set	idle_time_	0.0
$traffic set 	rate_	1Mb
$traffic attach-agent $src_udp2

#設定多媒體傳輸的起始時間
set rng [new RNG]
$rng seed 1
set RVstart [new RandomVariable/Uniform]
$RVstart set min_ 2
$RVstart set max_ 4
$RVstart use-rng $rng
set startT [expr [$RVstart value]]
set endT [expr ($startT + $end_sim_time)]
puts "startT: $startT sec"
puts "endT: $endT sec"

$ns at 0.1 "$ftp1 start"
$ns at 0.1 "$traffic start"
$ns at $startT "$video1 start"

$ns at 30.0 "$video1 stop"
$ns at 30.0 "$ftp1 stop"
$ns at 30.0 "$traffic stop"

#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    exit 0
}
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$n$i reset"
}
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
