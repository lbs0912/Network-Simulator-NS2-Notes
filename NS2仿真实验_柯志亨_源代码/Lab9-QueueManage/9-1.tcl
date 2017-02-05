if {$argc != 2} {
	puts "Usage: ns 9-1.tcl queuetype_noflows_"
	puts "Examples: ns 9-1.tcl myfifp 10"
	puts "queuetype_: myfifo or RED"
	exit
}

set par1 [lindex $argv 0]
set par2 [lindex $argv 1]

#create a simulator
set ns [new Simulator]

# open a trace file
set nd [open out-$par1-$par2.tr w]
$ns trace-all $nd

# define a finish process
proc finish {} {
	global ns nd par2 tcp startT
	$ns flush-trace
	close $nd

	set time [$ns now]
	set sum_thgpt 0

	#throughput = Ack * PacketSize(bit)/deliver time
	# Ack = Received Packet
	
	for {set i 0} {$i < $par2} {incr i} {
		set ackno_($i) [$tcp($i) set ack_ ]
		set thgpt($i) [expr $ackno_($i) * 1000.0 * 8.0 / ($time - $startT($i))]
		puts $thgpt($i)
		set sum_thgpt [ expr $sum_thgpt+$thgpt($i) ]
	}



	set avgthgpt [expr $sum_thgpt/$par2]
	puts "average throughput:$avgthgpt (bps)"
	
	exit 0

}

#create 20 nodes
for {set i 0} {$i < $par2} {incr i} {
	set src($i) [$ns node]
	set dst($i) [$ns node]
}

#create two router
set r1 [$ns node]
set r2 [$ns node]

#link node to router
for {set i 0} {$i < $par2} {incr i} {
	$ns duplex-link $src($i) $r1  100Mb [expr ($i*10)]ms DropTail
	$ns duplex-link $r2  $dst($i) 100Mb [expr ($i*10)]ms DropTail
}

$ns duplex-link $r1 $r2 56k 10ms $par1

#set Queue Size between routers
$ns queue-limit $r1 $r2 50

#trace queue length
set q_ [[$ns link $r1 $r2] queue]
set queuechan [open q-$par1-$par2.tr w]
$q_ trace curq_


if {$par1 == "RED"} {
	# use packet mode
	$q_ set bytes_ false
	$q_ set queue_in_bytes_ false
}



#$q_ attach $queuechan

$ns monitor-queue $r1 $r2 [open q-$par1-$par2.tr w] 0.3
[$ns link $r1 $r2] queue-sample-timeout

for {set i 0} {$i < $par2} {incr i} {
	set tcp($i) [$ns create-connection TCP/Reno $src($i) TCPSink  $dst($i) 0]
	$tcp($i) set fid_ $i  
}


# start data transfer randomly between 0s and 1s
set rng [new RNG] 
$rng seed 1

set RVStart [new RandomVariable/Uniform]
$RVStart set min_ 0
$RVStart set max_ 1
$RVStart use-rng $rng

# set data transfer starting time
for {set i 0} {$i < $par2} {incr i} {
	set startT($i) [expr [$RVStart value]]
	#puts "startT($i) $startT($i) sec"
}

# data transfer
for {set i 0} {$i < $par2} {incr i} {
	set ftp($i) [$tcp($i) attach-app FTP]
	$ns at startT($i) "$ftp($i) start"
}

$ns at 50.0 "finish"

$ns run















