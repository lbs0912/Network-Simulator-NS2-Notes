set ns [new Simulator]

set n0 [$ns node]
set n1 [$ns node]

$ns simplex-link $n0 $n1  1Mb 10ms DropTail
$ns simplex-link $n1 $n0 10Mb 10ms DropTail

set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
set tcpsink1 [new Agent/TCPSink/mTcpSink] 
$tcpsink1 set_filename tcp_sink
$ns attach-agent $n1 $tcpsink1
$ns connect $tcp $tcpsink1

set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

$ns at  0.0 "$ftp start"
$ns at 10.0 "$ns bandwidth $n0 $n1 5Mb"
$ns at 15.0 "$ftp stop"
$ns at 20.0 "$tcpsink1 closefile"
$ns at 20.1  "puts \"NS EXITING...\" ; $ns halt"

$ns run

