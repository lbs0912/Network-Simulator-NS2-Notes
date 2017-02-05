# 产生一个仿真对象
set ns [new Simulator]

#针对不同的数据流定义不同的颜色，这是要给NAM用的
$ns color 1 Blue
$ns color 2 Red

#打开一个NAM记录文件
set nf [open out.nam w]
$ns namtrace-all $nf

#打开一个仿真过程记录文件，用来记录封包传送的过程
set nd [open out.tr w]
$ns trace-all $nd

#定义一个结束的程序
proc finish {} {
	global ns nf nd
	$ns flush-trace
	close $nf
	close $nd
	#以背景执行的方式执行NAM
	exec nam out.nam &
	exit 0
}

# 产生传输结点，s1的id为０，s2的id为１
set s1 [$ns node]
set s2 [$ns node]

# 产生路由器结点，　ｒ的id为２
set r [$ns node]

#　产生数据接收结点，　ｄ的id为３
set d [$ns node]

# s1-r的链路具有2Mbps的频宽，10ms的传递延迟时间，DropTail的队列管理方式
# s2-r的链路具有2Mbps的频宽，10ms的传递延迟时间，DropTail的队列管理方式
# r-d的链路具有1.7Mbps的频宽，20ms的传递延迟时间，DropTail的队列管理方式
$ns duplex-link $s1 $r 2Mb   10ms DropTail
$ns duplex-link $s2 $r 2Mb   10ms DropTail
$ns duplex-link $r  $d 1.7Mb 20ms DropTail


# 设置ｒ到ｄ之间的Queue Limit为10个封包的大小
$ns queue-limit $r $d 10

#　设置结点的位置，这是要给NAM用的
$ns duplex-link-op $s1 $r orient right-down
$ns duplex-link-op $s2 $r orient right-up
$ns duplex-link-op $r $d orient right

#观测ｒ到ｄ之间queue的变化，这是要给NAM用的
$ns duplex-link-op $r $d queuePos 0.5

#　建立一条TCP的联机
set tcp [new Agent/TCP]
$ns attach-agent $s1 $tcp
# mTcpSink是TCPSink的延伸，除了具有TCPSink的功能外，也能记录所送出封包信息
set sink [new Agent/TCPSink/mTcpSink]
#　设置TCP接收记录文件的文件名为tcp_sink
$sink set_filename tcp_sink
$ns attach-agent $d $sink
$ns connect $tcp $sink

#在NAM中，TCP的联机会以蓝色表示
$tcp set fid_ 1

# 在TCP联机上建立FTP应用程序
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

#建立一条mUDP的联机
# mUDP是UDP的延伸，除了具有UDP的功能外，也能记录所送出的封包信息
set udp [new Agent/mUDP]
# 设置传送记录文件名为sd_udp
$udp set_filename sd_udp
$ns attach-agent $s2 $udp

# 新增的接收Agent，可以把接收封包信息记录到文件中
set null [new Agent/mUdpSink]
# 设置接收文件记录文件名为rd_udp
$null set_filename rd_udp
$ns attach-agent $d $null
$ns connect $udp $null

# 在NAM中，UDP的联机会以红色表示
$udp set fid_ 2

# 在UDP联机上建立CBR应用程序
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR

# 设置传送封装包的大小为1000 byte
$cbr set packet_size_ 1000

# 设置传送的速率为１Mbps
$cbr set rate_ 1mb
$cbr set random_ false

# 设置FTP和CBR数据传送开始和结束时间
$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 4.0 "$ftp stop"
$ns at 4.5 "$cbr stop"

# 结束TCP的联机（不一定需要写下面的程序代码来实际结束联机）
$ns at 4.5 "$ns detach-agent $s1 $tcp; $ns detach-agent $d $sink"

#　在模拟环境中，5s后去调用finish来结束模拟(这样要注意模拟环境中的5s并不一定等于实际模拟的时间)
$ns at 5.0 "finish"

# 执行模拟
$ns run












