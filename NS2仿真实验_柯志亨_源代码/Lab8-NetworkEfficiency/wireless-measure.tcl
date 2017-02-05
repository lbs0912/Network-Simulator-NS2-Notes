
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
set val(ifqlen) 50                         ;# max packet in ifq
set val(nn)     3                          ;# number of mobilenodes
set val(rp)     DSDV                       ;# routing protocol
set val(x)      1000                       ;# X dimension of topography
set val(y)      1000                       ;# Y dimension of topography
set val(stop)   1000.0                     ;# time of simulation end
set val(seed)   0.0                         
set val(tr)     exp.tr                     ;#trace file name                   
#===================================
#        Initialization        
#===================================
#Create a ns simulator
set ns_ [new Simulator]

#Open trace file
$ns_ use-newtrace
set namfd [open nam-exp.nam w]
$ns_ namtrace-all-wireless $namfd $val(x) $val(y)


set tracefd [open $val(tr) w]
$ns_ trace-all $tracefd

#Setup topography object  建立一拓扑对象，以记录结点在拓扑内移动的情况
set topo   [new Topography]
# 拓扑范围　1000*1000
$topo load_flatgrid $val(x) $val(y)

#create channel
set chan [new $val(chan)]

# create God
set god_ [create-god $val(nn)]

#===================================
#     Mobile node parameter setup
#===================================
$ns_ node-config -adhocRouting  $val(rp) \
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
                -macTrace      OFF \
                -movementTrace OFF

#===================================
#        Nodes Definition        
#===================================
for {set i 0} {$i < $val(nn)} {incr i} {
    set node_($i) [$ns_ node]
    # disable random motion
    $node_($i) random-motion 0   
}

# Provide initial (X,Y for now Z=0) co-ordinates for mobilenodes

# 设置结点０在一开始时的位置

$node_(0) set X_ 350.0
$node_(0) set Y_ 500.0
$node_(0) set Z_ 0.0

# 设置结点1在一开始时的位置
$node_(1) set X_ 500.0
$node_(1) set Y_ 500.0
$node_(1) set Z_ 0.0

# 设置结点2在一开始时的位置
$node_(2) set X_ 650.0
$node_(2) set Y_ 500.0
$node_(2) set Z_ 0.0

# Load the god object with shortest hop information
#　在结点１和结点２之间最短的hop为１
$god_ set-dist 1 2 1
#　在结点0和结点２之间最短的hop为2
$god_ set-dist 0 2 2
#　在结点0和结点1之间最短的hop为１
$god_ set-dist 0 1 1

#Now produce some simple node movements
# node(1) starts to move upwards and then downward
set god_ [God instance]

#===================================
#        Generate movement          
#===================================
# 在模拟时间200s的时候，结点１开始从位置(500,500)移动到(500,900)
# speed = 2.0m/sec
$ns_ at 200.0 "$node_(1) setdest 500.0 900.0 2.0"

# 在模拟时间500s的时候，结点１开始从位置(500,900)移动到(500,100)
# speed = 2.0m/sec
$ns_ at 500.0 "$node_(1) setdest 500.0 100.0 2.0"

# Steup traffice flow between nodes    0 connecting to 2  at time 100.0
# 在结点０和结点２之间建立一条CBR/UDP的联机，且在时间１００秒开始传送
set udp_(0) [new Agent/mUDP]
# 设置传送记录文件文件名为sd_udp
$udp_(0) set_filename sd_udp
$udp_(0) set fid_ 1
$ns_ attach-agent $node_(0) $udp_(0)

set null_(0) [new Agent/mUdpSink]
# 设置传送记录文件文件名为rd_udp
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



# Define node initial position in nam, only for nam
#　在nam中定义初始所在位置
for {set i 0} {$i < $val(nn)} {incr i} {
    # The function must be called after mobility model is defined
    $ns_ initial_node_pos $node_($i) 60
}

# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn)} {incr i} {
    # The function must be called after mobility model is defined
    $ns_ at $val(stop) "$node_($i) reset"
}
$ns_ at $val(stop) "stop"
#$ns_ at $val(stop) "puts\'NS EXISTING...\'; $ns_ halt"
#$ns_ at $val(stop) "puts\"NS EXITING...\"; $ns_ halt"

#$ns_ at $val(stop) "puts\"NS EXITING...\"; $ns_ halt"
#$ns_ at $val(stop) "puts\"NS EXITING...\";$ns_ halt"
#$ns_ at $val(stop)　"puts\"NS EXITING...\";$ns_ halt"

$ns_ at $val(stop)    "puts\"NS EXITING...\";$ns_ halt"
#$ns_ at $val(stop) "puts\"NS EXITING...\";$ns_ halt"
#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc stop {} {
    global ns_ tracefd namfd
    $ns_ flush-trace
    close $tracefd
    close $namfd
	exec nam nam-exp.nam &
	exit 0
}

puts "Starting Simulation..."

$ns_ run
