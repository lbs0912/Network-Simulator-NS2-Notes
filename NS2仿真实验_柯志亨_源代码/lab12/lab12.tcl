if {$argc !=1} {
	puts "Usage: ns lab12.tcl TCPversion "
	puts "Example:ns lab12.tcl Reno or ns lab12.tcl Newreno or ns lab12.tcl Sack"
	exit
}

set par1 [lindex $argv 0]

# 產生一個模擬的物件
set ns [new Simulator]

#開啟一個trace file，用來記錄封包傳送的過程
set nd [open out-$par1.tr w]
$ns trace-all $nd

#開啟一個檔案用來記錄cwnd變化情況
set f0 [open cwnd-$par1.tr w]

#定義一個結束的程序
proc finish {} {
        global ns nd f0 tcp par1
        
        #顯示最後的平均吞吐量
        puts [format "average throughput: %.1f Kbps" \
        	[expr [$tcp set ack_]*([$tcp set packetSize_])*8/1000.0/10]]
        $ns flush-trace
        
	    #關閉檔案
        close $nd
        close $f0
      
	    #使用awk分析記錄檔以觀察佇列的變化
    	exec awk {
		BEGIN {
			highest_packet_id = -1;
			packet_count = 0;
			q_eln = 0;
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

				if (action == "-" || action == "d") {
					q_eln = q_len--;
					print time, q_len;
				}
			}
		}
	} out-$par1.tr > queue_length-$par1.tr

        exit 0
}

#定義一個記錄的程序
#每格0.01秒就去記錄當時的cwnd
proc record {} {
	global ns tcp f0
	
	set now [$ns now]
	puts $f0 "$now [$tcp set cwnd_]"
	$ns at [expr $now+0.01] "record"
}

#產生傳送節點,路由器r1,r2和接收節點
set r0 [$ns node]
set r1 [$ns node]
set n0 [$ns node]
set n1 [$ns node]

#建立鏈路
$ns duplex-link $n0 $r0 10Mb 1ms DropTail
$ns duplex-link $r0 $r1 1Mb  4ms DropTail
$ns duplex-link $r1 $n1 10Mb 1ms DropTail

#設定佇列長度為15個封包大小
set buffer_size 15
$ns queue-limit $r0 $r1 $buffer_size

#根據使用者的設定,指定TCP版本
if {$par1=="Reno"} {
	set tcp [new Agent/TCP/Reno]
	set tcpsink [new Agent/TCPSink]
	$tcp set debug_ 0
} elseif {$par1=="Newreno"} {
	set tcp [new Agent/TCP/Newreno]
	set tcpsink [new Agent/TCPSink]
	$tcp set debug_ 0
} else {
	set tcp [new Agent/TCP/Sack1]
	set tcpsink [new Agent/TCPSink/Sack1]
	$tcp set debug_ 1
}

$ns attach-agent $n0 $tcp	

#將awnd的值設為24,這是advertised window的上限
# advertised window是接收端的緩衝區可以容納的封包個數，
#因此當congestion window的值超過advertised window時，
#TCP的傳送端會執行流量控制以避免送的太快而導致接收端的緩衝區溢滿。
$tcp set window_ 24	

$ns attach-agent $n1 $tcpsink
$ns connect $tcp $tcpsink

#建立FTP應用程式
set ftp [new Application/FTP]
$ftp attach-agent $tcp

#在0.0秒時,開始傳送
$ns at  0.0 "$ftp start"

#在10.0秒時,結束傳送
$ns at 10.0 "$ftp stop"

#在0.0秒時去呼叫record來記錄TCP的cwnd變化情況
$ns at  0.0 "record"

#在第10.0秒時去呼叫finish來結束模擬
$ns at 10.0 "finish"

#計算在傳輸路徑上大約可以容納多少的封包
#計算方式:在bottleneck link上每秒可以傳送的封包數*RTT+佇列緩衝區大小
puts [format "on path: %.2f packets" \
  [expr (1000000/(8*([$tcp set packetSize_]+40)) * ((1+4+1) * 2 * 0.001)) + $buffer_size]]

#執行模擬
$ns run
