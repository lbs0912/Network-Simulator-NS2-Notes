#create a simulator
set ns [new Simulator]

#若用户设定了使用距离相量(distance vector)算法的动态路由方式
#则设定路由的方式为Dv
if {$argc != 1} {
	puts "Usage: ns 12-1.tcl TCPVersion"
	puts "Example: ns 12-1.tcl Newreno or ns 11-1-.tcl Reno or ns 11-1-.tcl Sack"
	exit
}


set par1 [lindex $argv 0]


# open a TRACE file
set nd [open out-$par1.tr w]
$ns trace-all $nd

# open a cwnd file
set f0 [open cwnd-$par1.tr w]

# define a finish process
proc finish {} {
	global ns nd f0 tcp par1

	# 显示最后的平均吞吐量
	puts [format "Average Throughput: %.1f Kbps" \
			[expr [$tcp set ack_]*([$tcp set packetSize_])*8/1000.0/10]]
	$ns flush-trace
	close $nd
	close $f0



	#使用awk分析记录文件，以观察队列变化
	exec awk {
		BEGIN {
			highest_packet_id = -1;
			packet_count = 0;
			q_len = 0;
		}

		{
			action = $1;
			time= $2;
			src_node = $3;
			dst_node = $4;
			type = $5;
			flow_id = $8;
			seq_no = $11;
			packet_id = $12;



			if (src_node == "0" && dst_node == "1") {
				if (packet_id > highest_packet_id) {
					highest_packet_id = packet_id;
				}

				if (action == "+") {
					q_len++;
					print time, q_len;
				}

				if(action == "-" || action == "d") {
					q_len--;
					print time, q_len;
				}
			}
		}

	} out-$par1.tr > queue_length-$par1.tr

	exit 0
}

# define a record proc
proc record {} {
	global ns tcp f0
	set now [$ns now]
	puts $f0 "$now [$tcp set cwnd_]"
	$ns at [expr $now + 0.01] "record"
}

#create 5 nodes
set r0 [$ns node]
set r1 [$ns node]
set n0 [$ns node]
set n1 [$ns node]

# link nodes together
$ns duplex-link $n0 $r0 10Mb 1ms DropTail
$ns duplex-link $r0 $r1 1Mb 4ms DropTail
$ns duplex-link $r1 $n1 10Mb 1ms DropTail


# 设置队列长度是15个封包大小
set buffer_size 15
$ns queue-limit $r0 $r1 $buffer_size

# select TCP Version
if {$par1 == "Reno"} {
	set tcp [new Agent/TCP/Reno]
	set tcpsink [new Agent/TCPSink]
	$tcp set debug_ 1
} elseif {$par1 == "Newreno"} {
	set tcp [new Agent/TCP/Newreno]
	set tcpsink [new Agent/TCPSink]
	$tcp set debug_ 1
} else {
	set tcp [new Agent/TCP/Sack1]
	set tcpsink [new Agent/TCPSink/Sack1]
	$tcp set debug_ 1
}

$ns attach-agent $n0 $tcp

#将awnd的值设为24,这是advertised window的上限
# advertised window是接收端的缓冲区可以容纳的封包个数
# 因此，当congestion window的值超过advertised　window时
#　TCP的传送端会执行流量控制，以避免传送的太快而导致接收端的缓冲区溢满
$tcp set window_ 24


$ns attach-agent $n1 $tcpsink
$ns connect $tcp $tcpsink


# set FTP link
set ftp [new Application/FTP]
$ftp attach-agent $tcp


$ns at 0.0 "$ftp start"
$ns at 10.0 "$ftp stop"

$ns at 0.0 "record"
$ns at 10.0 "finish"

#计算在传输路径上大约可容纳多少个封包
#计算方式：　在bottleneck link　上每秒可以传送的封包数　×　RTT +　队列缓冲区大小　
puts [format "on path:%.2f packtes" \
			[expr (1000000/(8*([$tcp set packetSize_]+40))*((1+4+1)*2*0.001))+ $buffer_size]]

$ns run















