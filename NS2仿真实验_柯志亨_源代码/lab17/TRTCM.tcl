# 原作者: Jeremy Ethridge,
# 原創作日期: June 15-July 5, 1999.
# 註解: A DS-RED script that uses CBR traffic agents and the TRTCM Policer.

# 產生一個模擬的物件
set ns [new Simulator]

#開啟一個trace file，用來記錄封包傳送的過程
set nd [open trtcm.tr w]
$ns trace-all $nd

#設定第一個分組的CIR為1500000 bps, CBR為2000 bytes, PIR為3000000 bps, PBS為3000bytes
#設定第二個分組的CIR為1000000 bps, CBR為1000 bytes, PIR為2000000 bps, PBS為2000bytes
#設定第一個分組的CBR的傳送速率為4000000 bps, 第二組的為4000000 bps
set cir0  1500000
set cbs0     2000
set pir0  3000000
set pbs0     3000
set rate0 4000000
set cir1  1000000
set cbs1     1000
set pir1  2000000
set pbs1     2000
set rate1 4000000

#模擬時間為85秒,每個傳送的CBR的封包大小為1000 byte
set testTime 85.0
set packetSize 1000

# 設定網路模擬架構
set s1 [$ns node]
set s2 [$ns node]
set e1 [$ns node]
set core [$ns node]
set e2 [$ns node]
set dest [$ns node]

$ns duplex-link $s1 $e1 10Mb 5ms DropTail
$ns duplex-link $s2 $e1 10Mb 5ms DropTail

#指定e1為邊境路由器,core為核心路由器
$ns simplex-link $e1 $core 10Mb 5ms dsRED/edge
$ns simplex-link $core $e1 10Mb 5ms dsRED/core

#指定e2為邊境路由器
$ns simplex-link $core $e2 5Mb 5ms dsRED/core
$ns simplex-link $e2 $core 5Mb 5ms dsRED/edge

$ns duplex-link $e2 $dest 10Mb 5ms DropTail

#設定在nam中節點的位置關係圖
$ns duplex-link-op $s1 $e1 orient down-right
$ns duplex-link-op $s2 $e1 orient up-right
$ns duplex-link-op $e1 $core orient right
$ns duplex-link-op $core $e2 orient right
$ns duplex-link-op $e2 $dest orient right

#設定佇列名稱
set qE1C [[$ns link $e1 $core] queue]
set qE2C [[$ns link $e2 $core] queue]
set qCE1 [[$ns link $core $e1] queue]
set qCE2 [[$ns link $core $e2] queue]

#設定e1到core的參數
$qE1C meanPktSize $packetSize

#設定一個physical queue
$qE1C set numQueues_ 1

#設定三個virtual queue
$qE1C setNumPrec 3

#設定從s1到dest為第一個分組,採用TRTCM
#並把符合標準的封包標成綠色(10)
$qE1C addPolicyEntry [$s1 id] [$dest id] trTCM 10 $cir0 $cbs0 $pir0 $pbs0

#設定從s2到dest為第二個分組,採用TRTCM
#並把符合標準的封包標成綠色(10)
$qE1C addPolicyEntry [$s2 id] [$dest id] trTCM 10 $cir1 $cbs1 $pir1 $pbs1

#把不符合標準的封包標註成黃色(11)和紅色(12)
$qE1C addPolicerEntry trTCM 10 11 12

#把綠色(10)的封包放到第一個實際佇列中(0)的第一個虛擬佇列(0)
$qE1C addPHBEntry 10 0 0

#把黃色(11)的封包放到第一個實際佇列中(0)的第二個虛擬佇列(1)
$qE1C addPHBEntry 11 0 1

#把紅色(12)的封包放到第一個實際佇列中(0)的第三個虛擬佇列(2)
$qE1C addPHBEntry 12 0 2

#設定第一個實際佇列中(0)的第一個虛擬佇列(0)的RED參數
#{min, max, max drop probability} = {20 packets, 40 packets, 0.02}
$qE1C configQ 0 0 20 40 0.02

#設定第一個實際佇列中(0)的第二個虛擬佇列(1)的RED參數為{10, 20, 0.1}
$qE1C configQ 0 1 10 20 0.10

#設定第一個實際佇列中(0)的第二個虛擬佇列(2)的RED參數為{5, 10, 0.20}
$qE1C configQ 0 2  5 10 0.20

#設定e2到core的參數
$qE2C meanPktSize $packetSize
$qE2C set numQueues_ 1
$qE2C setNumPrec 3
$qE2C addPolicyEntry [$dest id] [$s1 id] trTCM 10 $cir0 $cbs0 $pir0 $pbs0
$qE2C addPolicyEntry [$dest id] [$s2 id] trTCM 10 $cir1 $cbs1 $pir1 $pbs1
$qE2C addPolicerEntry trTCM 10 11 12
$qE2C addPHBEntry 10 0 0
$qE2C addPHBEntry 11 0 1
$qE2C addPHBEntry 12 0 2
$qE2C configQ 0 0 20 40 0.02
$qE2C configQ 0 1 10 20 0.10
$qE2C configQ 0 2  5 10 0.20

#設定core到e1的參數
$qCE1 meanPktSize $packetSize
$qCE1 set numQueues_ 1
$qCE1 setNumPrec 3
$qCE1 addPHBEntry 10 0 0
$qCE1 addPHBEntry 11 0 1
$qCE1 addPHBEntry 12 0 2
$qCE1 configQ 0 0 20 40 0.02
$qCE1 configQ 0 1 10 20 0.10
$qCE1 configQ 0 2  5 10 0.20

#設定core到e2的參數
$qCE2 meanPktSize $packetSize
$qCE2 set numQueues_ 1
$qCE2 setNumPrec 3
$qCE2 addPHBEntry 10 0 0
$qCE2 addPHBEntry 11 0 1
$qCE2 addPHBEntry 12 0 2
$qCE2 configQ 0 0 20 40 0.02
$qCE2 configQ 0 1 10 20 0.10
$qCE2 configQ 0 2  5 10 0.20

#設定s1到dest的CBR參數
set udp0 [new Agent/UDP]
$ns attach-agent $s1 $udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$udp0 set class_ 1
$cbr0 set packet_size_ $packetSize
$udp0 set packetSize_ $packetSize
$cbr0 set rate_ $rate0
set null0 [new Agent/Null]
$ns attach-agent $dest $null0
$ns connect $udp0 $null0

#設定s2到dest的CBR參數
set udp1 [new Agent/UDP]
$ns attach-agent $s2 $udp1
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$udp1 set class_ 2
$cbr1 set packet_size_ $packetSize
$udp1 set packetSize_ $packetSize
$cbr1 set rate_ $rate1
set null1 [new Agent/Null]
$ns attach-agent $dest $null1
$ns connect $udp1 $null1

#定義一個結束的程序
proc finish {} {
        global ns nd
        $ns flush-trace
        close $nd 
        exit 0
}

#顯示在e1的SLA
$qE1C printPolicyTable
$qE1C printPolicerTable

$ns at 0.0 "$cbr0 start"
$ns at 0.0 "$cbr1 start"
$ns at $testTime "$cbr0 stop"
$ns at $testTime "$cbr1 stop"
$ns at [expr $testTime + 1.0] "finish"

$ns run
