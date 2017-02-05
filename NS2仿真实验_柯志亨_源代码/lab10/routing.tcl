set ns [new Simulator]

#若是使用者有指定使用距離相量(distance vector)演算法的動態路由方式
#則設定路由的方式為DV
if {$argc==1} {
	set par [lindex $argv 0]
	if {$par=="DV"} {
		$ns rtproto DV
	}
}

#設定資料傳送時,以藍色表示所傳送的封包
$ns color 1 Blue

#Open the NAM trace file
set file1 [open out.nam w]
$ns namtrace-all $file1

#定義結束程序
proc finish {} {
        global ns file1
        $ns flush-trace
        close $file1
        exec nam out.nam &
        exit 0
}

#產生五個節點
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

#把節點和路由器連接起來
$ns duplex-link $n0 $n1 0.5Mb 10ms DropTail
$ns duplex-link $n1 $n2 0.5Mb 10ms DropTail
$ns duplex-link $n1 $n3 0.5Mb 10ms DropTail
$ns duplex-link $n3 $n4 0.5Mb 10ms DropTail
$ns duplex-link $n3 $n2 0.5Mb 10ms DropTail

#設定節點在nam中所在的位置關係
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n1 $n3 orient down
$ns duplex-link-op $n3 $n4 orient right
$ns duplex-link-op $n3 $n2 orient right-up
 
#建立TCP連線
set tcp [new Agent/TCP]
$tcp set fid_ 1
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink

#建立FTP應用程式資料流
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

#設定在1.0秒時,n1到n3間的鏈路發生問題
$ns rtmodel-at 1.0 down $n1 $n3

#設定在2.0秒時,n1到n3間的鏈路又恢復正常
$ns rtmodel-at 2.0 up $n1 $n3

#在0.1秒時,FTP開始傳送資料
$ns at 0.1 "$ftp start"

#在3.0秒時,結束傳送資料
$ns at 3.0 "finish"

#模擬開始
$ns run
