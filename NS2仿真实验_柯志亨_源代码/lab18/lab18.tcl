#網路的拓樸
#有線網路節點--->(基地台)---->無線網路節點

#設定模擬結束時間
set opt(stop) 250

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

set pGG $opt(0)
set pBB $opt(1)
set pG $opt(2)
set pB $opt(3)
set loss_model  $opt(4)
#comm_type是用來設定當封包進入無線網路時,要用unicast還是multicast傳送
#0:multicast, 1:unicast
set comm_type  $opt(5)
#產生一個模擬的物件
set ns_ [new Simulator]

#設定最多重傳次數
Mac/802_11 set LongRetryLimit_    4

#若模擬的環境,是單純的有線網路,或無線網路,定址的方是使用flat即可(default設定)
#但是若包含了有線網路和無線網路,則就需要使用hierarchial addressing的方式定址
$ns_ node-config -addressType hierarchical

#設定有兩個domain(第一個domain是有線網路,第二個是無線網路)
AddrParams set domain_num_ 2

#每個domain各有一個cluster(每一個domain只包含一個子網路)
lappend cluster_num 1 1
AddrParams set cluster_num_ $cluster_num

#而在第一個domain,其第一個cluster中,只有一個有線網路節點
#而在地二個domain,其第一個cluster中,會有兩個無線網路節點,基地台算無線節點
lappend eilastlevel 1 2
AddrParams set nodes_num_ $eilastlevel

#設定記錄檔,把模擬過程都記錄下來
set tracefd [open test.tr w]
$ns_ trace-all $tracefd

#設定mobile host的個數
set opt(nnn) 1

# 拓樸的範圍為 100m x 100m
set topo [new Topography]
$topo load_flatgrid 100 100

#create god
#create-god要設定基地台個數+mobile host個數
set god_ [create-god [expr $opt(nnn)+$opt(num_FA)]]

#有線節點的位址
#因為此節點是屬於第一個domain,第一個cluster中的第一個節點,
#所以位址為0.0.0 (從0開始算起)
set W(0) [$ns_ node 0.0.0]

# create channel 
set chan_ [new Channel/WirelessChannel]

#設定節點參數
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

#設定基地台節點
#基地台是屬於第二個domain,第一個cluster中的第一個節點
#所以其位址為1.0.0 (從0開始)
set HA [$ns_ node 1.0.0]
#set HAnetif_ [$HA set netif_(0)]
#$HAnetif_ set-error-level $pGG $pBB $pG $pB $loss_model

#設定mobile host的參數
#不需要wired routing,所以把此功能off
$ns_ node-config -wiredRouting OFF

#Mobile host是屬於第二個domain,第一個cluster中的第二個節點
#所以其位址為1.0.1 (從0開始)
set MH(0) [$ns_ node 1.0.1]

#設定MH(0)的physical layer存取點
set MHnetif_(0) [$MH(0) set netif_(0)]

#在接收端的Physical layer設定packet error rate和packet error model
$MHnetif_(0) set-error-level $pGG $pBB $pG $pB $loss_model

#把此mobile host跟前面的基地台做連結
[$MH(0)  set regagent_] set home_agent_ [AddrParams addr2id [$HA node-addr]]

#設定基地台的位置在(100.0, 100.0)
$HA set X_ 100.0
$HA set Y_ 100.0
$HA set Z_ 0.0

#設定mobile host的位置在(80.0, 80.0)
$MH(0) set X_ 80.0
$MH(0) set Y_ 80.0
$MH(0) set Z_ 0.0

#在有線節點和基地台之間建立一條連線
$ns_ duplex-link $W(0) $HA 10Mb 10ms DropTail

$ns_ at $opt(stop).1 "$MH(0) reset";
$ns_ at $opt(stop).0001 "$W(0) reset"

#建立一個CBR的應用程式 (wired node ---> base station)
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

#當基地台收到cbr封包時,可以根據使用者設定以unicast或multicast轉送封包到mobile host
set forwarder_ [$HA  set forwarder_]
puts [$forwarder_ port]
$ns_ connect $udp0 $forwarder_
$forwarder_ dst-addr [AddrParams addr2id [$MH(0) node-addr]]
$forwarder_ comm-type $comm_type

#在2.4秒時,開始送出cbr封包
$ns_ at 2.4 "$cbr0 start"

#在200.0秒時,停止傳送
$ns_ at 200.0 "$cbr0 stop"

$ns_ at $opt(stop).0002 "stop "
$ns_ at $opt(stop).0003  "$ns_  halt"

#設定一個stop的程序 
proc stop {} {
    global ns_ tracefd
    
    #關閉記錄檔 
    close $tracefd
}

#執行模擬
$ns_ run
