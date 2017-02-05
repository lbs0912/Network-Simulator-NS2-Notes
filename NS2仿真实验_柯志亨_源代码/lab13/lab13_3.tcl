#Create a simulator object
set ns [new Simulator]

#Open trace file
set nf [open out.nam w]
$ns namtrace-all $nf
$ns trace-all [open out.tr w]

#Open output file for writing data (in TCL simulation script)
set f0 [open cwnd-vegas.tr w]
set f1 [open cwnd-reno.tr w]

set enable 	1
set disable	0
#Define a 'finish' procedure
proc finish {} {
        global ns nf f0 tcp0 f1 tcp1
        puts [format "Vegas -\tgoodput: %.1f Kbps" [expr [$tcp0 set ack_]*([$tcp0 set packetSize_])*8/1000.0/10]]
        puts [format "Reno -\tgoodput: %.1f Kbps" [expr [$tcp1 set ack_]*([$tcp1 set packetSize_])*8/1000.0/10]]
        
        $ns flush-trace
	#Close the trace file
        close $nf
        close $f0
        close $f1
	#Execute nam on the trace file
        #exec nam out.nam &
        exit 0
}

proc record {} {
	global ns tcp0 f0 tcp1 f1
	
	set now [$ns now]
	puts $f0 "$now [$tcp0 set cwnd_]"
	puts $f1 "$now [$tcp1 set cwnd_]"
	$ns at [expr $now+0.01] "record"
}

#Create two nodes
set r0 [$ns node]
set r1 [$ns node]
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

#Create a duplex link between the nodes
$ns duplex-link $n0 $r0 10Mb 1ms DropTail
$ns duplex-link $n2 $r0 10Mb 1ms DropTail
#$ns duplex-link $r0 $r1 1Mb  20ms DropTail
Queue/RED set thesh_ 10
Queue/RED set maxthresh_ 14
Queue/RED set linterm_ 1
$ns duplex-link $r0 $r1 1Mb  20ms RED
$ns duplex-link $r1 $n1 10Mb 1ms DropTail
$ns duplex-link $r1 $n3 10Mb 1ms DropTail

set buffer_size 15
$ns queue-limit $r0 $r1 $buffer_size

set tcp0 [new Agent/TCP/Vegas];
$tcp0 set v_alpha_ 1
$tcp0 set v_beta_ 3
$tcp0 set debug_ 0
$tcp0 set window_ 24		
$tcp0 set fid_ 0
$ns attach-agent $n0 $tcp0

set tcp0sink [new Agent/TCPSink]
$tcp0sink set fid_ 0
$ns attach-agent $n1 $tcp0sink

$ns connect $tcp0 $tcp0sink

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

set tcp1 [new Agent/TCP/Reno]
$tcp1 set window_ 24		
$tcp1 set fid_ 1
$ns attach-agent $n2 $tcp1

set tcp1sink [new Agent/TCPSink]
$tcp1sink set fid_ 1
$ns attach-agent $n3 $tcp1sink

$ns connect $tcp1 $tcp1sink

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

$ns at 00.0 "$ftp0 start"
$ns at 10.0 "$ftp0 stop"

$ns at 00.0 "$ftp1 start"
$ns at 10.0 "$ftp1 stop"


$ns at 00.0 "record"
$ns at 10.0 "finish"

#Run the simulation
$ns run
