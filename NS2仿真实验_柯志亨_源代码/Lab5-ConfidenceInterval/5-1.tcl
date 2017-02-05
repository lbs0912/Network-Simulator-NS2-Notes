# Usage: ns 5-1.tcl on-off 数据流参数的第几次实验
# Eg: ns 5-1.tcl 100 1 (rate_设置为100K，第１次实验)

if {$argc != 2} {
	puts "Usage: ns 5-1.tcl rate_ no_"
	exit
}

# par1 记录用户所设置的rate_ 
# par2 记录用户所设置的第几次实验 no_
set par1 [lindex $argv 0]
set par2 [lindex $argv 1] 

# 产生一个仿真对象
set ns [new Simulator]

#打开一个仿真过程记录文件，用来记录封包传送的过程
set nd [open data/out$par1-$par2.tr w]
$ns trace-all $nd

#打开一个NAM记录文件
#set nf [open data/out.nam w]
#$ns namtrace-all $nf


# crate 6 network node
set s1 [$ns node]
set s2 [$ns node]
set s3 [$ns node]
set d1 [$ns node]
set d2 [$ns node]
set d3 [$ns node]

# create 2 router node
set r1 [$ns node]
set r2 [$ns node]


# 定义一个结束程序
proc finish {} {
	global ns nd #nf
 
	$ns flush-trace
	close $nd

	#exec nam out.nam &
	exit 0
}

# link network node with router node together
$ns duplex-link $s1 $r1 10Mb 1ms DropTail
$ns duplex-link $s2 $r1 10Mb 1ms DropTail
$ns duplex-link $s3 $r1 10Mb 1ms DropTail
$ns duplex-link $r2 $r1 1Mb  10ms DropTail
$ns duplex-link $d1 $r2 10Mb 1ms DropTail
$ns duplex-link $d2 $r2 10Mb 1ms DropTail
$ns duplex-link $d3 $r2 10Mb 1ms DropTail


#　建立一条 s1-d1 的TCP的联机,并在TCP联机上建立FTP应用程序
set tcp1 [new Agent/TCP]
$ns attach-agent $s1 $tcp1

set sink1 [new Agent/TCPSink]
$ns attach-agent $d1 $sink1

$ns connect $tcp1 $sink1

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP




#　建立一条 s2-d2 的TCP的联机,并在TCP联机上建立FTP应用程序: 干扰数据流
set tcp2 [new Agent/TCP]
$ns attach-agent $s2 $tcp2

set sink2 [new Agent/TCPSink]
$ns attach-agent $d2 $sink2

$ns connect $tcp2 $sink2

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ftp2 set type_ FTP




#　建立一条 s3-d3 的on-off干扰数据流，具有exponential distribution
# 平均封包的大小是1000 bytes
# burst time: 0.5s  idle time:0s   rate:用户设置的传输速度
set udp [new Agent/UDP]
$ns attach-agent $s3 $udp

set null [new Agent/Null]
$ns attach-agent $d3 $null

$ns connect $udp $null

set traffic [new Application/Traffic/Exponential]
$traffic set packetSize_ 1000
$traffic set burst_time_ 0.5
$traffic set idle_time_ 0
$traffic set  rate_ [expr $par1*1000]
$traffic attach-agent $udp

# create different random numbers each time   set seed 0
set rng [new RNG]
$rng seed 0


set RVstart [new RandomVariable/Uniform]
$RVstart set min_ 3
$RVstart set max_ 4
$RVstart use-rng $rng



# 由随机数产生器决定每一条flow的起始时间(0~1s之内)
set startT  [expr [$RVstart value]]
puts "startT   $startT sec"

# 先让干扰的数据流消耗网络的资源
$ns at 0.0 "$ftp2 start"
$ns at 0.0 "$traffic start"
$ns at $startT "$ftp1 start"

$ns at 11.0 "$ftp1 stop"
$ns at 11.5 "$ftp2 stop"
$ns at 11.5 "$traffic stop"





#　在模拟环境中，7s后去调用finish来结束模拟(这样要注意模拟环境中的7s并不一定等于实际模拟的时间)
$ns at 12.0 "finish"

# 执行模拟
$ns run











