# This script is created by NSG2 beta1
# <http://wushoupong.googlepages.com/nsg>

set max_fragmented_size 1024
set packetSize [expr $max_fragmented_size+28]

#===================================
#     Simulation parameters setup
#===================================
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                       ;# max packet in ifq
set val(nn)     4                          ;# number of mobilenodes
set val(rp)     DSDV                       ;# routing protocol
set val(x)      500                      ;# X dimension of topography
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

#Open the NAM trace file
set namfile [open out.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)
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
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      ON \
                -movementTrace ON

#===================================
#        Nodes Definition        
#===================================
#Create 4 nodes
set n0 [$ns node]
$n0 set X_ 300
$n0 set Y_ 400
$n0 set Z_ 0.0
$ns initial_node_pos $n0 20
set n1 [$ns node]
$n1 set X_ 400
$n1 set Y_ 400
$n1 set Z_ 0.0
$ns initial_node_pos $n1 20
set n2 [$ns node]
$n2 set X_ 300
$n2 set Y_ 300
$n2 set Z_ 0.0
$ns initial_node_pos $n2 20
set n3 [$ns node]
$n3 set X_ 400
$n3 set Y_ 300
$n3 set Z_ 0.0
$ns initial_node_pos $n3 20

#===================================
#        Agents Definition        
#===================================
set udp1 [new Agent/my_UDP]
$ns attach-agent $n0 $udp1
$udp1 set_filename sd1
$udp1 set packetSize_ $packetSize

set null1 [new Agent/myEvalvid_Sink] 
$ns attach-agent $n1 $null1
$null1 set_filename rd1

$ns connect $udp1 $null1

set udp2 [new Agent/my_UDP]
$ns attach-agent $n2 $udp2
$udp2 set_filename sd2
$udp2 set packetSize_ $packetSize

set null2 [new Agent/myEvalvid_Sink] 
$ns attach-agent $n3 $null2
$null2 set_filename rd2

$ns connect $udp2 $null2

#===================================
#        Applications Definition        
#===================================

#第一條video flow
#設定要讀取的video traffic trace
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
  	set prio_p 0
    }	

    if { $frametype_ == "P" } {
  	set type_v 2
  	set prio_p 0
    }	

    if { $frametype_ == "B" } {
  	set type_v 3
  	set prio_p 0
    }	
    
    if { $frametype_ == "H" } {
  	set type_v 1
  	set prio_p 0
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
$video1 attach-agent $udp1
$video1 attach-tracefile $trace_file

$ns at 2.0 "$video1 start"
$ns at $end_sim_time "$video1 stop"
$ns at $end_sim_time "$null1 closefile"

#第二條video flow
#設定要讀取的video traffic trace,這裡使用相同影片
#若是有別的影片,就修改成其他影片的traffic trace file
set original_file_name2 foreman_qcif.st
set trace_file_name2 video2.dat
set original_file_id2 [open $original_file_name2 r]
set trace_file_id2 [open $trace_file_name2 w]

set pre_time 0

while {[eof $original_file_id2] == 0} {
    gets $original_file_id2 current_line
     
    scan $current_line "%d%s%d%d%f" no_ frametype_ length_ tmp1_ tmp2_
    set time [expr int(($tmp2_ - $pre_time)*1000000.0)]
          
    if { $frametype_ == "I" } {
  	set type_v 1
  	set prio_p 0
    }	

    if { $frametype_ == "P" } {
  	set type_v 2
  	set prio_p 0
    }	

    if { $frametype_ == "B" } {
  	set type_v 3
  	set prio_p 0
    }	
    
    if { $frametype_ == "H" } {
  	set type_v 1
  	set prio_p 0
    }

    puts  $trace_file_id2 "$time $length_ $type_v $prio_p $max_fragmented_size"
    set pre_time $tmp2_
}

close $original_file_id2
close $trace_file_id2
set end_sim_time2 [expr $tmp2_+5.0]
puts "$end_sim_time2"

set trace_file2 [new Tracefile]
$trace_file2 filename $trace_file_name2
set video2 [new Application/Traffic/myEvalvid]
$video2 attach-agent $udp2
$video2 attach-tracefile $trace_file2

$ns at 2.1 "$video2 start"
$ns at $end_sim_time2 "$video2 stop"
$ns at $end_sim_time2 "$null2 closefile"

set udp3 [new Agent/UDP]
$ns attach-agent $n3 $udp3
set null3 [new Agent/Null]
$ns attach-agent $n0 $null3
$ns connect $udp3 $null3

set cbr3 [new Application/Traffic/CBR]
$cbr3 attach-agent $udp3
$cbr3 set type_ CBR
$cbr3 set packet_size_ 1000
$cbr3 set rate_ 150kb
$cbr3 set random_ false

set udp4 [new Agent/UDP]
$ns attach-agent $n1 $udp4
set null4 [new Agent/Null]
$ns attach-agent $n2 $null4
$ns connect $udp4 $null4

set cbr4 [new Application/Traffic/CBR]
$cbr4 attach-agent $udp4
$cbr4 set type_ CBR
$cbr4 set packet_size_ 1000
$cbr4 set rate_ 130kb
$cbr4 set random_ false

$ns at 1.0 "$cbr3 start"
$ns at 1.3 "$cbr4 start"

#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    #exec nam out.nam &
    exit 0
}
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$n$i reset"
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
