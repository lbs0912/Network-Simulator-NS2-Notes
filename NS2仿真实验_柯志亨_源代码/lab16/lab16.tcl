#
# Copyright (c) Xerox Corporation 1997. All rights reserved.
#
# License is granted to copy, to use, and to make and to use derivative
# works for research and evaluation purposes, provided that Xerox is
# acknowledged in all documentation pertaining to any such copy or
# derivative work. Xerox grants no other licenses expressed or
# implied. The Xerox trade name should not be used in any advertising
# without its written permission. 
#
# XEROX CORPORATION MAKES NO REPRESENTATIONS CONCERNING EITHER THE
# MERCHANTABILITY OF THIS SOFTWARE OR THE SUITABILITY OF THIS SOFTWARE
# FOR ANY PARTICULAR PURPOSE.  The software is provided "as is" without
# express or implied warranty of any kind.
#
# These notices must be retained in any copies of any part of this
# software. 
#


# This example script demonstrates using the token bucket filter as a
# traffic-shaper. 
# There are 2 identical source models(exponential on/off) connected to a common
# receiver. One of the sources is connected via a tbf whereas the other one is 
# connected directly.The tbf parameters are such that they shape the exponential
# on/off source to look like a cbr-like source.

#這個範例主要是在展示如何使用令牌桶資料流整形器的使用
#有兩個相同傳送模型(exponential on/off)資料傳送端都會把資料送到同一個接收端
#而這個傳送端中的一個在送出資料前會先經過整形才會送出資料,另一個則直接送出
#令牌桶資料流整形器的參數主要就是希望能然exponential on/off的資料傳送端在
#送出資料的行為能像CBR那樣,具有固定速率的特性

#產生一個模擬的物件
set ns [new Simulator]

#產生節點
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

#開啟一個模擬過程記錄檔，用來記錄封包傳送的過程
set f [open out.tr w]
$ns trace-all $f

#開啟一個NAM 記錄檔
set nf [open out.nam w]
$ns namtrace-all $nf

#set trace_flow 1

#針對不同的資料流定義不同的顏色，這是要給NAM用的
$ns color 0 red
$ns color 1 blue

#產生鏈路
$ns duplex-link $n2 $n1 0.2Mbps 100ms DropTail
$ns duplex-link $n0 $n1 0.2Mbps 100ms DropTail

#設定節點的位置，這是要給NAM用的
$ns duplex-link-op $n2 $n1 orient right-down
$ns duplex-link-op $n0 $n1 orient right-up

#建立一個Exponential on/off的應用程式
set exp1 [new Application/Traffic/Exponential]

#設定封包大小
$exp1 set packetSize_ 128

#設定on的時間
$exp1 set burst_time_ [expr 20.0/64]

#設定off的時間
$exp1 set idle_time_ 325ms

#設定速率
$exp1 set rate_ 65.536k

#設定UDP
set a [new Agent/UDP]

#設定flow id為1
$a set fid_ 0

$exp1 attach-agent $a

#設定一個令牌桶資料流整形器
set tbf [new TBF]

#設定桶子深度
$tbf set bucket_ 1024

#設定令牌補充速率
$tbf set rate_ 32.768k

#設定緩衝區大小 (100個packet)
$tbf set qlen_  100

$ns attach-tbf-agent $n0 $a $tbf

#設定接收端
set rcvr [new Agent/SAack]
$ns attach-agent $n1 $rcvr

#連接傳送端和接收端
$ns connect $a $rcvr

#建立另一個Exponential on/off的應用程式
set exp2 [new Application/Traffic/Exponential]

#設定封包大小
$exp2 set packetSize_ 128

#設定on的時間
$exp2 set burst_time_ [expr 20.0/64]

#設定off的時間
$exp2 set idle_time_ 325ms

#設定速率
$exp2 set rate_ 65.536k

#設定UDP
set a2 [new Agent/UDP]

#設定flow id為1
$a2 set fid_ 1

$exp2 attach-agent $a2
$ns attach-agent $n2 $a2

#連接傳送端和接收端
$ns connect $a2 $rcvr

#在0.0秒時, exp1和exp2開使傳送封包
$ns at 0.0 "$exp1 start;$exp2 start"

#在20.0秒時,exp1和exp2停止傳送,並且關閉記錄檔,最後再執行NAM
$ns at 20.0 "$exp1 stop;$exp2 stop;close $f;close $nf;exec nam out.nam &;exit 0"
$ns run



