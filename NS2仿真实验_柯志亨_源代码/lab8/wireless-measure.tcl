# Define options 定義一些變數
#===========================================================
set val(chan)	    Channel/WirelessChannel       ;# channel type
set val(prop)		Propagation/TwoRayGround  	;#radio-propagation model
set val(netif)		Phy/WirelessPhy          		;# network interface type
set val(mac)		Mac/802_11               	;# MAC type
set val(ifq) 		Queue/DropTail/PriQueue   	;# interface queue type
set val(ll)          LL                        ;# link layer type
set val(ant)        Antenna/OmniAntenna       	;# antenna model (天線模型)
set val(x) 	    1000			            ;#拓樸範圍:X
set val(y) 	    1000			            ;#拓樸範圍:Y
set val(ifqlen)     50                    		;# max packet in ifq
set val(nn)        3                           ;# number of mobile nodes 
set val(seed)	    0.0
set val(stop)	    1000.0			             ;# simulation time
set val(tr)	        exp.tr			             ;# trace file name
set val(rp)        DSDV                 		 ;# routing protocol 

# Initialize Global Variables
set ns_		[new Simulator]

# Open trace file 開啟trace file
$ns_ use-newtrace                          
set namfd 	[open nam-exp.tr w]
$ns_ namtrace-all-wireless $namfd $val(x) $val(y)
set tracefd     [open $val(tr) w]
$ns_ trace-all $tracefd

# set up topography object 
#建立一個拓樸物件,以紀錄mobilenodes在拓樸內移動的情況
set topo       [new Topography]

# 拓樸的範圍為 1000m x 1000m
$topo load_flatgrid $val(x) $val(y)

# create channel 
set chan [new $val(chan)]

# Create God
set god_ [create-god $val(nn)]

#  Create the specified number of mobile nodes [$val(nn)] and "attach" them
#  to the channel. Three nodes are created : node(0), node(1) and node(2)
#  設置Mobile node的參數
	$ns_ node-config -adhocRouting $val(rp) \
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
			 -routerTrace ON \
			 -macTrace OFF \
			 -movementTrace OFF			
			 
	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0		;# disable random motion
	}

# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
# 設定節點0在一開始時，位置在(350.0, 500.0)
$node_(0) set X_ 350.0
$node_(0) set Y_ 500.0
$node_(0) set Z_ 0.0

# 設定節點1在一開始時，位置在(500.0, 500.0)
$node_(1) set X_ 500.0
$node_(1) set Y_ 500.0
$node_(1) set Z_ 0.0

# 設定節點2在一開始時，位置在(650.0, 500.0)
$node_(2) set X_ 650.0
$node_(2) set Y_ 500.0
$node_(2) set Z_ 0.0

# Load the god object with shortest hop information
# 在節點1和節點2之間最短的hop數為1
$god_ set-dist 1 2 1

# 在節點0和節點2之間最短的hop數為2
$god_ set-dist 0 2 2

# 在節點0和節點1之間最短的hop數為1
$god_ set-dist 0 1 1

# Now produce some simple node movements
# Node_(1) starts to move upward and then downward
set god_ [God instance]

# 在模擬時間200秒的時候，節點1開始從位置(500, 500)移動到(500, 900)，
# 速度為2.0 m/sec
$ns_ at 200.0 "$node_(1) setdest 500.0 900.0 2.0"

# 然後在500秒的時候，再從位置(500, 900)移動到(500, 100)，速度為2.0 m/sec
$ns_ at 500.0 "$node_(1) setdest 500.0 100.0 2.0"

# Setup traffic flow between nodes   0 connecting to 2 at time 100.0
# 在節點0和節點2建立一條CBR/UDP的連線，且在時間為100秒開始傳送
set udp_(0) [new Agent/mUDP]
#設定傳送記錄檔檔名為sd_udp
$udp_(0) set_filename sd_udp
$udp_(0) set fid_ 1
$ns_ attach-agent $node_(0) $udp_(0)
set null_(0) [new Agent/mUdpSink]
#設定接收檔記錄檔檔名為rd_udp
$null_(0) set_filename rd_udp
$ns_ attach-agent $node_(2) $null_(0)

set cbr_(0) [new Application/Traffic/CBR]
$cbr_(0) set packetSize_ 200
$cbr_(0) set interval_ 2.0
$cbr_(0) set random_ 1
$cbr_(0) set maxpkts_ 10000
$cbr_(0) attach-agent $udp_(0)
$ns_ connect $udp_(0) $null_(0)
$ns_ at 100.0 "$cbr_(0) start"

#Define node initial position in nam, only for nam
# 在nam中定義節點初始所在位置
for {set i 0} {$i < $val(nn)} {incr i} {
	# The function must be called after mobility model is defined.
	$ns_ initial_node_pos $node_($i) 60
}

# Tell nodes when the simulation ends
# 設定節點模擬結束時間
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop)  "$node_($i) reset";
}
$ns_ at $val(stop)  "stop"
$ns_ at $val(stop)  "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd namfd
    $ns_ flush-trace
    close $tracefd
    close $namfd
}
puts "Starting Simulation..."
$ns_ run
