#網路的拓樸
#   Video               MyUdpSink
#   W(0) ------ HA------MH(0)

#設定base station的數目
set opt(num_FA) 1

#讀取使用者設定的參數
proc getopt {argc argv} {
	global opt
        lappend optlist nn
        for {set i 0} {$i < $argc} {incr i} {
		set opt($i) [lindex $argv $i]
	}
}

getopt $argc $argv

#設定Good ->Good的機率 
set pGG $opt(0)

#設定Bad -> Bad的機率
set pBB $opt(1)

#Good->Bad的機率為pGB=1-pGG;
#Bad->Good的機率為pBG=1-pBB;
#在steady state時在Good state的機率為piG=pBG/(pBG+pGB);
#在steady state時在Bad state的機率為piB=pGB/(pBG+pGB);

#在Good state,時packet發生error的機率
set pG $opt(2)

#在bad state,時packet發生error的機率
set pB $opt(3)

set seed $opt(4)
set max_fragmented_size $opt(5)
set packetSize [expr $max_fragmented_size+28]

#loss_model: 0 for uniform distribution, 1 for GE model
set loss_model  0

#comm_type: 0 for broacdcast, 1 for unicast
set comm_type 0

#產生一個模擬的物件
set ns_ [new Simulator]

#使用hierarchial addressing的方式定址
$ns_ node-config -addressType hierarchical

puts [ns-random $seed]

#設定有兩個domain,每個domain各有一個cluster
#第一個cluster(wired)有一個node,第二個cluster(wireles)有兩個node (base state + mobile node)
AddrParams set domain_num_ 2
lappend cluster_num 1 1
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 1 2
AddrParams set nodes_num_ $eilastlevel

#設定記錄檔,把模擬過程都記錄下來
set tracefd [open bsc_multicast.tr w]
$ns_ trace-all $tracefd

#設定mobile node的個數
set opt(nnn) 1

# 拓樸的範圍為 100m x 100m
set topo [new Topography]
$topo load_flatgrid 100 100

#create god
set god_ [create-god [expr $opt(nnn)+$opt(num_FA)]]

# wired nodes
set W(0) [$ns_ node 0.0.0]

# create channel 
set chan_ [new Channel/WirelessChannel]

#設定節點參數
$ns_ node-config -mobileIP ON \
	          -adhocRouting DSDV \
                  -llType LL \
                  -macType Mac/802_11 \
                  -ifqType Queue/DropTail/PriQueue \
                  -ifqLen 2000 \
                  -antType Antenna/OmniAntenna \
		  -propType Propagation/TwoRayGround \
		  -phyType Phy/WirelessPhy \
                  -channel $chan_ \
	 	  -topoInstance $topo \
                  -wiredRouting ON\
		  -agentTrace OFF \
                  -routerTrace OFF \
                  -macTrace OFF

#設定base station節點
set HA [$ns_ node 1.0.0]
set HAnetif_ [$HA set netif_(0)]
$HAnetif_ set-error-level $pGG $pBB $pG $pB $loss_model

#設定mobile node的參數
#不需要wired routing,所以把此功能off
$ns_ node-config -wiredRouting OFF
set MH(0) [$ns_ node 1.0.1]
set MHnetif_(0) [$MH(0) set netif_(0)]
$MHnetif_(0) set-error-level $pGG $pBB $pG $pB $loss_model
#把此mobile node跟前面的base station節點做連結
[$MH(0)  set regagent_] set home_agent_ [AddrParams addr2id [$HA node-addr]]

#設定base station的位置在(100.0, 100.0)
$HA set X_ 100.0
$HA set Y_ 100.0
$HA set Z_ 0.0

#設定mobile node的位置在(80.0, 80.0)
$MH(0) set X_ 80.0
$MH(0) set Y_ 80.0
$MH(0) set Z_ 0.0

#在wired node和base station之間建立一條連線
$ns_ duplex-link $W(0) $HA 10Mb 10ms myfifo
set q1	[[$ns_ link $W(0) $HA] queue]

set udp1 [new Agent/my_UDP]
$ns_ attach-agent $W(0) $udp1
$udp1 set_filename sd
$udp1 set packetSize_ $packetSize

set forwarder_ [$HA  set forwarder_]
puts [$forwarder_ port]
$ns_ connect $udp1 $forwarder_
$forwarder_ dst-addr [AddrParams addr2id [$MH(0) node-addr]]
$forwarder_ comm-type $comm_type

set null1 [new Agent/myEvalvid_Sink] 
$ns_ attach-agent $MH(0) $null1
$null1 set_filename rd
$MH(0) attach $null1 3

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

$ns_ at 0.0 "$video1 start"
$ns_ at $end_sim_time "$video1 stop"
$ns_ at $end_sim_time "$null1 closefile"
$ns_ at $end_sim_time "$q1 printstatus"
$ns_ at $end_sim_time "$null1 printstatus"
$ns_ at $end_sim_time.1 "$MH(0) reset";
$ns_ at $end_sim_time).0001 "$W(0) reset"
$ns_ at $end_sim_time.0002 "stop "
$ns_ at $end_sim_time.0003  "$ns_  halt"

#設定一個stop的程序 
proc stop {} {
    global ns_
    global tracefd
    
    #關閉記錄檔 
    close $tracefd
}

#執行模擬
$ns_ run
