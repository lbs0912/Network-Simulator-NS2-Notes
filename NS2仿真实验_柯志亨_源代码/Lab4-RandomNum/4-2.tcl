# 产生一个仿真对象
set ns [new Simulator]

#打开一个仿真过程记录文件，用来记录封包传送的过程
set nd [open out.tr w]
$ns trace-all $nd

#打开一个NAM记录文件
set nf [open out.nam w]
$ns namtrace-all $nf


# 设置TCP flow的数目
set nflow 3

# 产生并设置路由器结点
set r1 [$ns node]
set r2 [$ns node]
$ns duplex-link $r1 $r2 1Mb 10ms DropTail

# 设置queue limint为10个packet
$ns queue-limit $r1 $r2 10

# 设置TCP的来源结点，目的结点，并分别建立二者与路由器的链路
for {set i 1} {$i <= $nflow} {incr i} {
	set s($i) [$ns node]
	set d($i) [$ns node]

	$ns duplex-link  $s($i) $r1 10Mb 1ms DropTail
	$ns duplex-link  $r2 $d($i) 10Mb 1ms DropTail
}


#　建立一条TCP的联机,并在TCP联机上建立FTP应用程序
for {set i 1} {$i <= $nflow} {incr i} {
	set tcp($i) [new Agent/TCP]
	set sink($i) [new Agent/TCPSink]
	$ns attach-agent $s($i) $tcp($i)
	$ns attach-agent $d($i) $sink($i)
    $ns connect $tcp($i) $sink($i)

	set ftp($i) [new Application/FTP]
	$ftp($i) attach-agent $tcp($i)
	$ftp($i) set type_ FTP
}

# 产生随机数
set rng [new RNG]
$rng seed 1

#set RVstart [new RandomVariable/Uniform]
set RVstart [new RandomVariable/Pareto]
$RVstart set avg_ 1.0
$RVstart set shape_ 1.2
$RVstart use-rng $rng






# 由随机数产生器决定每一条flow的起始时间(0~1s之内)，　每条flow传输5s
# 并在指定的时间内，让ftp开始传输和结束


for {set i 1} {$i <= $nflow} {incr i} {
	set startT($i) [expr [$RVstart value]]
	puts "startT($i)  $startT($i) sec"

	
	set endT($i) [expr ($startT($i)+5)]
	puts "endT($i)  $endT($i) sec"

	$ns at $startT($i) "$ftp($i) start"
	$ns at $endT($i) "$ftp($i) stop" 
}



# 定义一个结束程序
proc finish {} {
	global ns nd nf
 	
	
	close $nd
	$ns flush-trace
	
	exec nam out.nam &
	exit 0
}

#　在模拟环境中，7s后去调用finish来结束模拟(这样要注意模拟环境中的7s并不一定等于实际模拟的时间)
$ns at 7.0 "finish"

# 执行模拟
$ns run











