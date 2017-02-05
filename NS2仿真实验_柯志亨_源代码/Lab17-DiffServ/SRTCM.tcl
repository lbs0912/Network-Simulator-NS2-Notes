
set ns [new Simulator]


set nd [open srtcm.tr w]
$ns trace-all $nd

set cir0  1500000
set cbs0     2000
set ebs0     3000
set rate0 4000000
set cir1  1000000
set cbs1     1000
set ebs1     2000
set rate1 4000000


set testTime 85.0
set packetSize 1000


set s1 [$ns node]
set s2 [$ns node]
set e1 [$ns node]
set core [$ns node]
set e2 [$ns node]
set dest [$ns node]

$ns duplex-link $s1 $e1 10Mb 5ms DropTail
$ns duplex-link $s2 $e1 10Mb 5ms DropTail


$ns simplex-link $e1 $core 10Mb 5ms dsRED/edge
$ns simplex-link $core $e1 10Mb 5ms dsRED/core


$ns simplex-link $core $e2 5Mb 5ms dsRED/core
$ns simplex-link $e2 $core 5Mb 5ms dsRED/edge

$ns duplex-link $e2 $dest 10Mb 5ms DropTail


$ns duplex-link-op $s1 $e1 orient down-right
$ns duplex-link-op $s2 $e1 orient up-right
$ns duplex-link-op $e1 $core orient right
$ns duplex-link-op $core $e2 orient right
$ns duplex-link-op $e2 $dest orient right


set qE1C [[$ns link $e1 $core] queue]
set qE2C [[$ns link $e2 $core] queue]
set qCE1 [[$ns link $core $e1] queue]
set qCE2 [[$ns link $core $e2] queue]


$qE1C meanPktSize $packetSize

$qE1C set numQueues_ 1


$qE1C setNumPrec 3


$qE1C addPolicyEntry [$s1 id] [$dest id] srTCM 10 $cir0 $cbs0 $ebs0


$qE1C addPolicyEntry [$s2 id] [$dest id] srTCM 10 $cir1 $cbs1 $ebs1


$qE1C addPolicerEntry srTCM 10 11 12


$qE1C addPHBEntry 10 0 0

$qE1C addPHBEntry 11 0 1


$qE1C addPHBEntry 12 0 2


$qE1C configQ 0 0 20 40 0.02


$qE1C configQ 0 1 10 20 0.10


$qE1C configQ 0 2  5 10 0.20


$qE2C meanPktSize $packetSize
$qE2C set numQueues_ 1
$qE2C setNumPrec 3
$qE2C addPolicyEntry [$dest id] [$s1 id] srTCM 10 $cir0 $cbs0 $ebs0
$qE2C addPolicyEntry [$dest id] [$s2 id] srTCM 10 $cir1 $cbs1 $ebs1
$qE2C addPolicerEntry srTCM 10 11 12
$qE2C addPHBEntry 10 0 0
$qE2C addPHBEntry 11 0 1
$qE2C addPHBEntry 12 0 2
$qE2C configQ 0 0 20 40 0.02
$qE2C configQ 0 1 10 20 0.10
$qE2C configQ 0 2  5 10 0.20


$qCE1 meanPktSize $packetSize
$qCE1 set numQueues_ 1
$qCE1 setNumPrec 3
$qCE1 addPHBEntry 10 0 0
$qCE1 addPHBEntry 11 0 1
$qCE1 addPHBEntry 12 0 2
$qCE1 configQ 0 0 20 40 0.02
$qCE1 configQ 0 1 10 20 0.10
$qCE1 configQ 0 2  5 10 0.20


$qCE2 meanPktSize $packetSize
$qCE2 set numQueues_ 1
$qCE2 setNumPrec 3
$qCE2 addPHBEntry 10 0 0
$qCE2 addPHBEntry 11 0 1
$qCE2 addPHBEntry 12 0 2
$qCE2 configQ 0 0 20 40 0.02
$qCE2 configQ 0 1 10 20 0.10
$qCE2 configQ 0 2  5 10 0.20


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


proc finish {} {
        global ns nd
        $ns flush-trace
        close $nd 
        exit 0
}


$qE1C printPolicyTable
$qE1C printPolicerTable

$ns at 0.0 "$cbr0 start"
$ns at 0.0 "$cbr1 start"
$ns at $testTime "$cbr0 stop"
$ns at $testTime "$cbr1 stop"
$ns at [expr $testTime + 1.0] "finish"

$ns run
