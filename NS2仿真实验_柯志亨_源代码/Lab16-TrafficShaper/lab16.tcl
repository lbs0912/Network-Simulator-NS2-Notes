set ns [new Simulator]

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

set f [open out.tr w]
$ns trace-all $f

set nf [open out.nam w]
$ns namtrace-all $nf

$ns color 0 red
$ns color 1 blue

$ns duplex-link $n2 $n1 0.2Mbps 100ms DropTail
$ns duplex-link $n1 $n0 0.2Mbps 100ms DropTail

$ns duplex-link-op $n2 $n1 orient right-down
$ns duplex-link-op $n0 $n1 orient right-up

set exp1 [new Application/Traffic/Exponential]
 
$exp1 set packetSize_ 128
$exp1 set burst_time_ [expr 20.0/64]

$exp1 set idle_time_ 325ms

$exp1 set rate_ 65.536k

set a [new Agent/UDP]

$a set fid_ 0

$exp1 attach-agent $a

set tbf [new TBF]
$tbf set bucket_ 1024
$tbf set rate_ 32.768k
$tbf set qlen_ 100

$ns attach-tbf-agent $n0 $a $tbf

set rcvr [new Agent/SAack]
$ns attach-agent $n1 $rcvr
$ns connect $a $rcvr

set exp2 [new Application/Traffic/Exponential]
 
$exp2 set packetSize_ 128
$exp2 set burst_time_ [expr 20.0/64]
$exp2 set idle_time_ 325ms
$exp2 set rate_ 65.536k

set a2 [new Agent/UDP]

$a2 set fid_ 1

$exp2 attach-agent $a2
$ns attach-agent $n2 $a2

$ns connect $a2 $rcvr

$ns at 0.0 "$exp1 start;$exp2 start"

$ns at 20.0 "$exp1 stop;$exp2 stop; close $f;close $nf;exec nam out.nam &;exit 0"

$ns run