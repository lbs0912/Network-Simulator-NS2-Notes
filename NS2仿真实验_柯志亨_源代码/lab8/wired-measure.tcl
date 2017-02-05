# 產生一個模擬的物件
set ns [new Simulator]

#針對不同的資料流定義不同的顏色，這是要給NAM用的
$ns color 1 Blue
$ns color 2 Red

#開啟一個NAM 記錄檔
set nf [open out.nam w]
$ns namtrace-all $nf

#開啟一個模擬過程記錄檔，用來記錄封包傳送的過程
set nd [open out.tr w]
$ns trace-all $nd

#定義一個結束的程序
proc finish {} {
        global ns nf nd
        $ns flush-trace
        close $nf
        close $nd 
        #以背景執行的方式去執行NAM
        #exec nam out.nam &
        exit 0
}

#產生傳輸節點, s1的id為0, s2的id為1
set s1 [$ns node]
set s2 [$ns node]

#產生路由器節點, r的id為2
set r [$ns node]

#產生資料接收節點, d的id為3
set d [$ns node]

#s1-r的鏈路具有2Mbps的頻寬,10ms的傳遞延遲時間,DropTail的佇列管理方式
#s2-r的鏈路具有2Mbps的頻寬,10ms的傳遞延遲時間,DropTail的佇列管理方式
#r-d的鏈路具有1.7Mbps的頻寬,20ms的傳遞延遲時間,DropTail的佇列管理方式

$ns duplex-link $s1 $r 2Mb 10ms DropTail
$ns duplex-link $s2 $r 2Mb 10ms DropTail
$ns duplex-link $r $d 1.7Mb 20ms DropTail

#設定r到d之間的Queue Limit為10個封包大小
$ns queue-limit $r $d 10

#設定節點的位置，這是要給NAM用的
$ns duplex-link-op $s1 $r orient right-down
$ns duplex-link-op $s2 $r orient right-up
$ns duplex-link-op $r $d orient right

#觀測r到d之間queue的變化，這是要給NAM用的
$ns duplex-link-op $r $d queuePos 0.5

#建立一條TCP的連線
set tcp [new Agent/TCP]
$ns attach-agent $s1 $tcp
# mTcpSink是TCPsink的延申，除了具有TCPSink的功能外，也能記錄所送出封包資訊
set sink [new Agent/TCPSink/mTcpSink]
#設定tcp接收記錄檔的檔名為tcp_sink
$sink set_filename tcp_sink
$ns attach-agent $d $sink
$ns connect $tcp $sink
#在NAM中，TCP的連線會以藍色表示
$tcp set fid_ 1

#在TCP連線之上建立FTP應用程式
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

#建立一條mUDP的連線
#mUDP是UDP的延申，除了具有UDP的功能外，也能記錄所送出封包資訊
set udp [new Agent/mUDP]
#設定傳送記錄檔檔名為sd_udp
$udp set_filename sd_udp
$ns attach-agent $s2 $udp
#新增的接收Agent，可以把接收封包資訊記錄到檔案中
set null [new Agent/mUdpSink]
#設定接收檔記錄檔檔名為rd_udp
$null set_filename rd_udp
$ns attach-agent $d $null
$ns connect $udp $null
#在NAM中，UDP的連線會以紅色表示
$udp set fid_ 2

#在UDP連線之上建立CBR應用程式
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
#設定傳送封包的大小為1000 byte
$cbr set packet_size_ 1000
#設定傳送的速率為1Mbps
$cbr set rate_ 1mb
$cbr set random_ false

#設定FTP和CBR資料傳送開始和結束時間
$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 4.0 "$ftp stop"
$ns at 4.5 "$cbr stop"

#結束TCP的連線(不一定需要寫下面的程式碼來實際結束連線)
$ns at 4.5 "$ns detach-agent $s1 $tcp ; $ns detach-agent $d $sink"

#在模擬環境中，5秒後去呼叫finish來結束模擬(這樣要注意模擬環境中
#的5秒並不一定等於實際模擬的時間
$ns at 5.0 "finish"

#執行模擬
$ns run
