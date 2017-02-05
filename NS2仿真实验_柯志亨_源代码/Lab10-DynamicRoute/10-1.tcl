#create a simulator
set ns [new Simulator]

#若用户设定了使用距离相量(distance vector)算法的动态路由方式
#则设定路由的方式为Dv
if {$argc == 1} {
	set par [lindex $argv 0]
	if {$par == "DV"} {
		$ns rtproto DV
	}
}

#设置数据传输时，以蓝色表示所传送的封包
$ns color 1 Blue

# open a NAM file
set file1 [open out.nam w]
$ns namtrace-all $file1

# define a finish process
proc finish {} {
	global ns file1
	$ns flush-trace
	close $file1

	exec nam out.nam &
	exit 0
}

#create 5 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]


# link nodes together
$ns duplex-link $n0 $n1 0.5Mb 10ms DropTail
$ns duplex-link $n1 $n2 0.5Mb 10ms DropTail
$ns duplex-link $n1 $n3 0.5Mb 10ms DropTail
$ns duplex-link $n3 $n2 0.5Mb 10ms DropTail
$ns duplex-link $n3 $n4 0.5Mb 10ms DropTail

# set nodes' location in NAM
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n1 $n3 orient down
$ns duplex-link-op $n3 $n4 orient right
$ns duplex-link-op $n3 $n2 orient right-up



# set TCP link
set tcp [new Agent/TCP]
$tcp set fid_ 1
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink

# set FTP link
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

# Error occurs in the link between n1 and n3 at 1.0 second
$ns rtmodel-at 1.0 down $n1 $n3

#Link between n1 and n3 becomes normal at 2.0 second
$ns rtmodel-at 2.0 up $n1 $n3
# FTP deliver starts at 0.1 second

$ns at 0.1 "$ftp start"
$ns at 3.0 "finish"

$ns run















