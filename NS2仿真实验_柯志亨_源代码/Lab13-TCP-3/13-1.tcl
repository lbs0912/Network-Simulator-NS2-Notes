#create a simulator
set ns [new Simulator]

# open a TRACE file
set nd [open out-13-1.tr w]
$ns trace-all $nd

# open a cwnd file
set f0 [open cwnd0.tr w]
set f1 [open cwnd1.tr w]

# define a finish process
proc finish {} {
	global ns nd f0 tcp0 f1 tcp1
	# puts "ACK number:[$tcp0 set ack_]"

	$ns flush-trace

	close $nd
	close $f0
	close $f1



	#使用awk分析记录文件，以观察队列变化
	exec awk {
		BEGIN {
			highest_packet_id = -1;
			packet_count = 0;
			q_len = 0;
		}

		{
			action = $1;
			time = $2;
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

	} out-13-1.tr > queue-length-13-1.tr

	exit 0
}

# define a record proc 每个0.1秒就去记录当时的cwnd
proc record {} {
	global ns tcp0 f0 tcp1 f1
	set now [$ns now]
	puts $f0 "$now [$tcp0 set cwnd_]"
	puts $f1 "$now [$tcp1 set cwnd_]"
	$ns at [expr $now + 0.01] "record"
}

#create 5 nodes
set r0 [$ns node]
set r1 [$ns node]
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

# link nodes together
$ns duplex-link $n0 $r0 10Mb 1ms DropTail
$ns duplex-link $r0 $n2 10Mb 1ms DropTail
$ns duplex-link $r1 $r0 1Mb  20ms DropTail
$ns duplex-link $r1 $n1 10Mb 1ms DropTail
$ns duplex-link $r1 $n3 10Mb 1ms DropTail


# 设置队列长度是15个封包大小
set buffer_size 15
$ns queue-limit $r0 $r1 $buffer_size

# establish TCP Vegas' FTP connect
set tcp0 [new Agent/TCP/Vegas]
$tcp0 set v_alpha_ 1
$tcp0 set v_beta_ 3
$tcp0 set window_ 24
$ns attach-agent $n0 $tcp0

set tcp0sink [new Agent/TCPSink]
$ns attach-agent $n1 $tcp0sink
$ns connect $tcp0sink $tcp0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

# establish another TCP Vegas' FTP connect
set tcp1 [new Agent/TCP/Vegas]
$tcp1 set v_alpha_ 1
$tcp1 set v_beta_ 2
$tcp1 set window_ 24
$ns attach-agent $n2 $tcp1

set tcp1sink [new Agent/TCPSink]
$ns attach-agent $n3 $tcp1sink
$ns connect $tcp1sink $tcp1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1






$ns at 0.0 "$ftp0 start"
$ns at 10.0 "$ftp0 stop"

$ns at 5.0 "$ftp1 start"
$ns at 10.0 "$ftp1 stop"

$ns at 0.0 "record"
$ns at 10.0 "finish"


$ns run















