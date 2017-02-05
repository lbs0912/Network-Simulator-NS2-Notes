# Network Simulator (NS2) Notes

@(Research_Science)[NS2| Network Simulator]
> Ns is a discrete event simulator targeted at networking research. Ns provides substantial support for simulation of TCP, routing, and multicast protocols over wired and wireless (local and satellite) networks.

* 本文主要对NS2学习和使用过程中遇到的问题进行记录
* 本文主要参考了柯志亨的《NS2仿真实验》书籍
* [The Network Simulator - ns-2](http://www.isi.edu/nsnam/ns/)
* [柯志亨《NS2仿真实验》](https://book.douban.com/subject/3655281/)
* 柯志亨《NS2仿真实验》书籍的源代码和NS2模块配置与修改可以参见[Github-lbs0912](https://github.com/lbs0912/Network-Simulator-NS2-Notes)

[TOC]
## 1. Install NS2
### 1.1 Install NS2 on Ubuntu 14.04
#### 1.1.1  Update System
```
sudo apt-get update   #更新源列表
sudo apt-get upgrade   #更新已安装的包
sudo apt-get dist-upgrade   #更新软件，升级系统
```
#### 1.1.2 Install essential software packages
```
sudo apt-get install build-essential   
sudo apt-get install tcl8.5 tcl8.5-dev tk8.5 tk8.5-dev   #for tcl and tk
sudo apt-get install libxmu-dev libxmu-headers   #for nam
```
#### 1.1.3 Download and install NS2 package
Download [NS-allinone](http://www.isi.edu/nsnam/ns/ns-build.html) and install it.
>Ns-allinone is a package which contains equired components and some optional components used in running ns. The package contains an "install" script to automatically configure, compile and install these components. After downloading, run the install script. If you haven't installed ns before and want to quickly try ns out, ns-allinone may be easier than getting all the pieces by hand.

After downloading NS2 package, run the following code in terminal to unzip the package. 
```
tar xvfz ns-allinone-2.35.tar.gz
```
Then copy these files to "Home/lbs/ProgramFiles" directory and run the following code to install NS2.
```
cd ns-allinone-2.35
./install   #进行安装
```
Usually,  you'll encounter some problems. Don't be afraid and just fix them. For example, I come across the following problem:
```
linkstate/ls.h:137:58: note: declarations in dependent base ‘std::map<int, LsIdSeq, std::less<int>, std::allocator<std::pair<const int, LsIdSeq> > >’ are not found by unqualified lookup

linkstate/ls.h:137:58: note: use ‘this->erase’ instead
make: *** [linkstate/ls.o] Error 1

Ns make failed!

See http://www.isi.edu/nsnam/ns/ns-problems.html for problems
```
If you encounter this problem, you just need to modify the `ls.h` file in `ns-2.35/linkstate` directory according to the error information.

Open `ls.h` and find  line 137(according to the error information), then modify 
```
void eraseAll() { erase(baseMap::begin(), baseMap::end()); }
```
to
```
void eraseAll() { this->erase(baseMap::begin(), baseMap::end()); }
```
After that, just run`./install` again to install NS2. You can also use [Google](www.google.com) to help you solve problems.

If you install NS2 successfully, the terminal will appear the information:
```
Ns-allinone package has been installed successfully.
Here are the installation places:
tcl8.5.10:	/home/lbs/ProgramFiles/ns-allinone-2.35/{bin,include,lib}
tk8.5.10:		/home/lbs/ProgramFiles/ns-allinone-2.35/{bin,include,lib}
otcl:		/home/lbs/ProgramFiles/ns-allinone-2.35/otcl-1.14
tclcl:		/home/lbs/ProgramFiles/ns-allinone-2.35/tclcl-1.20
ns:		/home/lbs/ProgramFiles/ns-allinone-2.35/ns-2.35/ns
nam:	/home/lbs/ProgramFiles/ns-allinone-2.35/nam-1.15/nam
xgraph:	/home/lbs/ProgramFiles/ns-allinone-2.35/xgraph-12.2
gt-itm:   /home/lbs/ProgramFiles/ns-allinone-2.35/itm, edriver, sgb2alt, sgb2ns, sgb2comns, sgb2hierns

```

There are also some tips:
```
Ns-allinone package has been installed successfully.
Here are the installation places:
tcl8.5.10:	/home/lbs/ProgramFiles/ns-allinone-2.35/{bin,include,lib}
tk8.5.10:		/home/lbs/ProgramFiles/ns-allinone-2.35/{bin,include,lib}
otcl:		/home/lbs/ProgramFiles/ns-allinone-2.35/otcl-1.14
tclcl:		/home/lbs/ProgramFiles/ns-allinone-2.35/tclcl-1.20
ns:		/home/lbs/ProgramFiles/ns-allinone-2.35/ns-2.35/ns
nam:	/home/lbs/ProgramFiles/ns-allinone-2.35/nam-1.15/nam
xgraph:	/home/lbs/ProgramFiles/ns-allinone-2.35/xgraph-12.2
gt-itm:   /home/lbs/ProgramFiles/ns-allinone-2.35/itm, edriver, sgb2alt, sgb2ns, sgb2comns, sgb2hierns
```
We will use the tips in Step 4 to modify path environment.

#### 1.1.4  Modify path environment 
Modify `PATH`，`LD_LIBRARY_PATH`，`TCL_LIBRARY` path environment according to the terminal tips.

Open a new terminal window (or you need to change the directory to the initial directory in terminal) and run the following code.
```
sudo gedit .bashrc
```
Open `.bashrc` file and add this setting to the end of the file.
```
export PATH=$PATH:/home/lbs/ProgramFiles/ns-allinone-2.35/bin:/home/lbs/ProgramFiles/ns-allinone-2.35/tcl8.5.10/unix:/home/lbs/ProgramFiles/ns-allinone-2.35/tk8.5.10/unix
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/lbs/ProgramFiles/ns-allinone-2.35/otcl-1.14:/home/lbs/ProgramFiles/ns-allinone-2.35/lib
export TCL_LIBRARY=$TCL_LIBRARY:/home/lbs/ProgramFiles/ns-allinone-2.35/tcl8.5.10/library
# 注意两个环境变量路径之间要用冒号：隔开   
# Modify-lbs-20161103
```
At last, you should run 
```
source .bashrc
```
to finish the modification of path environment.
#### 1.1.5  Testify the installment
To testify the installment, we can input `ns` in terminal,  and if the terminal return back `%`, it shows that you have successfully installed NS2.　

You can also use the following ways to testify the installment.
```
cd ns-allinone-2.35/ns-2.35/tcl/ex
ns example.tcl
```
If you run the code, the terminal will show you some data.
![enter image description here](http://oda53d5ps.bkt.clouddn.com/Screenshot%20from%202016-11-03%2016:01:09.png)
Then, you can run the following code, the console window of nam and the help window of name will be opened. 
```
ns simple.tcl
```

![enter image description here](http://oda53d5ps.bkt.clouddn.com/Screenshot%20from%202016-11-03%2016:09:38.png)
![enter image description here](http://oda53d5ps.bkt.clouddn.com/Screenshot%20from%202016-11-03%2016:09:51.png)
### 1.2 Install NS2 on Windows System
#### 1.2.1  Install Cygwin
Open [Cygwin](http://www.cygwin.com/) website to install Cygwin.Note that by default Cygwin does not install all packages neccessary to run NS2. A user needs to manually install the addition packages shown in Table 1-1.

   Table 1-1 Additional Cygwin packages required to run NS2

|Category|Package|
|:-------|:------|
|Development|gcc, gcc-objc, gcc-g++, make|
|Utils|patch|
|X11|xorg-x11-base, xorg-x11-devel|
|Others|gzip, tar, gnuplot, gawk,XFree86-base, XFree86-bin,XFree86-prog, XFree86-lib, XFree86-etc, perl|

You should also install packages whose prefix are diff in case you encounter some errors. Go to [Reference 3](http://blog.sina.com.cn/s/blog_49ff68a00100hl5s.html) for more detail.

After the installment of Cygwin, please open Cygwin to generate a folder(`D:\cygwin64\home\lbs`,You can use `pwd` command in Cygwin to query the folder) which contains `.bashrc`, `.bashrc_profile`, `.profile` and `.inputrc`. These files are about path environment. 
 
You can use `cygcheck -c -d` command to show the installed packages. Command `cygcheck -c -d | grep regexp` can alos be used to show the version of choosen and installed packages, `regexp` is used to choose packages.

#### 1.2.2 Install NS2
Open Cygwin and run the following command.

```
tar xvfz ns-allinone-2.35.tar.gz
cd ns-allinone-2.35
./install   #进行安装
```
You may come across the following error: `Checking for gcc4....No!`


![enter image description here](http://oda53d5ps.bkt.clouddn.com/need-gcc4.png)

`GCC-4` has been already obsoleted in Cygwin. You can install `gcc5` in the items list of Cygwin. To install `gcc4`, you can first download `gcc4` at [here](https://gcc.gnu.org/).I choose to download [gcc-4.8.0.tar.gz](http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.8.0/) here.

Second, please put the file to directory `"D:\cygwin64\home\lbs"` and unzip the file.
```
tar xvfz gcc-4.8.0.tar.gz
```
Third, please input the following command.
```
cd gcc-4.8.0
./contrib/download_prerequisites
./configure
cd ..
mkdir build-gcc
cd build-gcc
$PWD/../gcc-4.8.0/configure --prefix=$HOME/gcc-4.8.0 --enable-languages=c,c++,fortran,go
make
make install
```
The `make` step takes a long time. If your computer has multiple processors or cores you can speed it up by building in parallel using `make -j 2` (or a higher number for more parallelism).
### 1.3 Reference
[1] [Ubuntu 14.04下安装ns2.35](http://www.linuxidc.com/Linux/2016-03/128820.htm)
[2] [ubuntu 12.04 安装 ns2.35](http://forum.ubuntu.org.cn/viewtopic.php?f=122&t=449640)
[3] [windows下安装NS2](http://blog.sina.com.cn/s/blog_49ff68a00100hl5s.html)
[4] [Windows下安装NS2详细步骤](http://wenku.baidu.com/view/fa409b6fb84ae45c3b358c52.html)
[5] [Installing GCC _ GCC Wiki](https://gcc.gnu.org/wiki/InstallingGCC)
[6] [linux 安装问题make: 没有指明目标并且找不到makefile](http://blog.csdn.net/suibianshen2012/article/details/48676395)
[7] [How to Install the Latest GCC on Windows](http://preshing.com/20141108/how-to-install-the-latest-gcc-on-windows/)

##2. Add mUDP & mUdpSink & mTcpSink modules 
### 2.1 Download modules 
You can downlaod  `mUdp.cc`,`mUdp.h`,`mUdpSink.cc`,`mUdpSink.h`,`mTcpSink.cc` and `mTcpSink.h` files from Baidu Pan at [here](https://pan.baidu.com/s/1dFr8tBb). You can also download these modules from `CSDN` at []here](http://download.csdn.net/download/joanna_yan/8232917). 
###2.2 Create a folder
Create a new folder whose name is `measure`. The `measure` folder should be existed in`/home/lbs/ProgramFiles/ns-allinone-2.35/ns-2.35/measure`. Then, put these module files into the folder. 
###2.3  Modify `packet.h` file
Open `packet.h` file which exists in`/home/lbs/ProgramFiles/ns-allinone-2.35/ns-2.35/common/`, and add the following code into `struct hdr_cmn{}`(in line 599).
```
//------------------------
//add by lbs  2016-11-18
int frametype_;
double  sendtime_;  
unsigned int pkt_id_; 
unsigned int frame_pkt_id_; 
//------------------------
```
### 2.4  Modify `Makefile` & `Makefile.in` files
 Add the following code to `Makefile` & `Makefile.in` files which lie in `/home/lbs/ProgramFiles/ns-allinone-2.35/ns-2.35/`. Remember to use `TAB` key instead of  `SPACE` key.
```
measure/mudp.o measure/mudpsink.o \
measure/mtcpsink.o \
```

### 2.5 Modify `ns-default.tcl` file
Add the following code to `ns-default.tcl` file  which lies in `/home/lbs/ProgramFiles/ns-allinone-2.35/ns-2.35/tcl/lib`. The following code should be placed after `line 830 : Agent/Ping set packetSize_ 64`.
```
#------------------------------
# add by lbs 2016-11-17
Agent/mUDP set packetSize_ 1000
#------------------------------
```
### 2.6 Configure & Make
Change you directory to `/home/lbs/ProgramFiles/ns-allinone-2.35/ns-2.35/` in the terminal, and run the following command.
```
./configure --with-tcl-ver=8.5
make clean
make
```
You may encounter the following error: `cannot call constructor 'mUdpAgent::UdpAgent' directly [-fpermissive] UdpAgent::UdpAgent`.

![enter image description here](http://oda53d5ps.bkt.clouddn.com/Screenshot%20from%202016-11-18%2018-13-21.png)

To solve the problem, you can delete `UdpAgent::UdpAgent` in your  `mUdp.cc` file.
```
mUdpAgent::mUdpAgent() : id_(0), openfile(0)
{
	bind("packetSize_", &size_);
	//UdpAgent::UdpAgent();   modify by lbs  2016-11-17  line 19
}
```
### 2.7 Reference
[1] [mUDP,mUdpSink,mTcpsink的添加](http://blog.csdn.net/huiquyiduxian/article/details/46984975) 
[2] [mUDP,mUdpSink,mTcpsink 下载](http://download.csdn.net/download/joanna_yan/8232917)

## 3. Add myfifo module
### 3.1 Create myfifo.cc & myfifo.h
Open `/home/ProgramFiles/ns-allinone-2.35/ns-2.35/queue` directory. Copy `drop-tail.cc` and `drop-tail.h` files and then, rename the copied files with `myfifo.cc` and `myfifo.h`.
### 3.2  Modify myfifo.cc & myfifo.h
* Modify `myfifo.h`
Use `myfifo` to replace all `DropTail`and`drop_tail`.
* Modify `myfifo.cc`
Use `myfifo` to replace all `DropTail`,`drop-tail`and`drop_tail`.
### 3.3  Modify ns-default.tcl
Open `/home/ProgramFiles/ns-allinone-2.35/ns-2.35/tcl/lib` directory. Then open `ns-default.tcl` file and find setting of `DropTail`.
```
Queue/DropTail set drop_front_ false
Queue/DropTail set summarystats_ false
Queue/DropTail set queue_in_bytes_ false
Queue/DropTail set mean_pktsize_ 500
```
Copy the four lines command and paste behind them. Last, change `DropTail`to `myfifo`.
```
Queue/myfifo set drop_front_ false
Queue/myfifo set summarystats_ false
Queue/myfifo set queue_in_bytes_ false
Queue/myfifo set mean_pktsize_ 500
```
### 3.4  Modify Makefile & Makefile.in file
Open `/home/ProgramFiles/ns-allinone-2.35/ns-2.35` directory. Then open `Makefile` and `Makefile.in` file.
Change 
```
queue/queue.o queue/drop-tail.o \
```
to
```
queue/queue.o queue/drop-tail.o queue/myfifo.o \
```
### 3.5 Configure & Make
Change you directory to `/home/lbs/ProgramFiles/ns-allinone-2.35/ns-2.35/` in the terminal, and run the following command.
```
./configure --with-tcl-ver=8.5
make clean
make
```
### 3.6 Reference
[1] [Add myfifo module－柯志亨](http://csie.nqu.edu.tw/smallko/ns2_old/module.htm)

## 4. 《NS2仿真实验》－柯志亨　学习笔记
### 4.1 Lab1  安装篇
### 4.2 Lab2  TCL语言简介
### 4.3 Lab3  TCL和UDP模拟实验
### 4.4 Lab4  随机数产生器
### 4.5 Lab5  置信区间
### 4.6 Lab6  nsBench
### 4.7 Lab7  网络脚本生成器NSG
### 4.8 Lab8 网络效率测量
#### 4.8.1  Add mUDP & mUdpSink & mTcpSink modules
Please refer `2.Add mUDP & mUdpSink & mTcpSink modules` in the notes.
#### 4.8.2 Modify the code of the book
* Change `set namfd [open nam-expr.tr w]` to `set namfd [open nam-expr.nam w]`
 
### 4.9 Lab9  队列管理机制
#### 4.9.1 Add myfifo module 
Please refer `3.Add myfifo module` in the notes.
#### 4.9.2 Modify the code of the book
* Change `set thgpt($i) [expr $ackno_($i) * 1000.0 * 8.0 / ($time - $start($i))]` to 
```
set thgpt($i) [expr $ackno_($i) * 1000.0 * 8.0 / ($time - $startT($i))]`
```
* Change `#$q_ attach $queuechan` to 
```
$ns monitor-queue $r1 $r2 [open q-$par1-$par2.tr w] 0.3
[$ns link $r1 $r2] queue-sample-timeout
```
* The whole code of Tcl 
```
if {$argc != 2} {
	puts "Usage: ns 9-1.tcl queuetype_noflows_"
	puts "Examples: ns 9-1.tcl myfifp 10"
	puts "queuetype_: myfifo or RED"
	exit
}

set par1 [lindex $argv 0]
set par2 [lindex $argv 1]

#create a simulator
set ns [new Simulator]

# open a trace file
set nd [open out-$par1-$par2.tr w]
$ns trace-all $nd

# define a finish process
proc finish {} {
	global ns nd par2 tcp startT
	$ns flush-trace
	close $nd

	set time [$ns now]
	set sum_thgpt 0

	#throughput = Ack * PacketSize(bit)/deliver time
	# Ack = Received Packet
	
	for {set i 0} {$i < $par2} {incr i} {
		set ackno_($i) [$tcp($i) set ack_ ]
		set thgpt($i) [expr $ackno_($i) * 1000.0 * 8.0 / ($time - $startT($i))]
		puts $thgpt($i)
		set sum_thgpt [ expr $sum_thgpt+$thgpt($i) ]
	}



	set avgthgpt [expr $sum_thgpt/$par2]
	puts "average throughput:$avgthgpt (bps)"
	
	exit 0

}

#create 20 nodes
for {set i 0} {$i < $par2} {incr i} {
	set src($i) [$ns node]
	set dst($i) [$ns node]
}

#create two router
set r1 [$ns node]
set r2 [$ns node]

#link node to router
for {set i 0} {$i < $par2} {incr i} {
	$ns duplex-link $src($i) $r1  100Mb [expr ($i*10)]ms DropTail
	$ns duplex-link $r2  $dst($i) 100Mb [expr ($i*10)]ms DropTail
}

$ns duplex-link $r1 $r2 56k 10ms $par1

#set Queue Size between routers
$ns queue-limit $r1 $r2 50

#trace queue length
set q_ [[$ns link $r1 $r2] queue]
set queuechan [open q-$par1-$par2.tr w]
$q_ trace curq_


if {$par1 == "RED"} {
	# use packet mode
	$q_ set bytes_ false
	$q_ set queue_in_bytes_ false
}

#$q_ attach $queuechan

$ns monitor-queue $r1 $r2 [open q-$par1-$par2.tr w] 0.3
[$ns link $r1 $r2] queue-sample-timeout

for {set i 0} {$i < $par2} {incr i} {
	set tcp($i) [$ns create-connection TCP/Reno $src($i) TCPSink  $dst($i) 0]
	$tcp($i) set fid_ $i  
}


# start data transfer randomly between 0s and 1s
set rng [new RNG] 
$rng seed 1

set RVStart [new RandomVariable/Uniform]
$RVStart set min_ 0
$RVStart set max_ 1
$RVStart use-rng $rng

# set data transfer starting time
for {set i 0} {$i < $par2} {incr i} {
	set startT($i) [expr [$RVStart value]]
	#puts "startT($i) $startT($i) sec"
}

# data transfer
for {set i 0} {$i < $par2} {incr i} {
	set ftp($i) [$tcp($i) attach-app FTP]
	$ns at startT($i) "$ftp($i) start"
}

$ns at 50.0 "finish"

$ns run
```

* Changes when using gnuplot
Instead of
```
plot "q-myfifo-10.tr" using 2:3 with linespoints,"q-RED-10.tr" using 2:3 with linespoints
```
You should use the following command
```
plot "q-myfifo-10.tr" using 1:5 with linespoints,"q-RED-10.tr" using 1:5 with linespoints
```
`using 1:5`	means  data of list 1 is used for x-axis and data of list 5 is used for y-axis. 
#### 4.9.3  Reference
[1] [NS2队列管理机制](http://blog.sina.com.cn/s/blog_620882f401010orx.html)

### 4.10 Lab10  动态路由
### 4.11 Lab11 各种TCP版本（一）
### 4.12 Lab12 各种TCP版本（二）
### 4.13 Lab13 各种TCP版本（三）
### 4.14 Lab14 TCP同步化现象
### 4.15 Lab15 影响TCP效果的几个因素
### 4.16 Lab16 流量整形器
### 4.17 Lab17 差异式服务网络
###4.18 Lab18 无线网络封包传输遗失模型
#### 4.18.1 NS2中无线遗失模型
在原本的NS2无线网络结构中，封包从传送段送出，若是没有发生碰撞且接收端在接收信号允许的范围内，则接收端一定可以成功地接收到封包。在此假设下，是没有考虑传输过程中封包发生错误的情形。

为此，可以修改ns2安装目录下的mac文件夹下的`wireless-phy.cc`，添加随机统一模型与连续性遗失模型，用来仿真封包从传送端到接收端的传输过程中可能发生的错误情形。

这里需要特别注意的是，由于传输遗失模型只在接收端作用，所以若是属于双向传输(如`TCP`)的话，也要在传送端加上无线遗失模型。
#### 4.18.2 NS2中无线遗失模型的添加方法
* Download [wireless-error-model.rar](http://csie.nqu.edu.tw/smallko/ns2_old/wireless_error_model.rar)
* Copy `noah` directory in `wireless-error-model.rar` to  `/home/lbs/ProgramFiles/ns-allinone-2.35/ns-2.35`
* Add `noah.tcl` to `.../ns-allinone-2.35/ns-2.35/tcl/mobility`
* Modify `Makefile` & `Makefile.in`
Add `noah/noah.o \` to OBJ_CC and `tcl/mobility/noah.tcl \ `to NS_TCL_LIB.
```
OBJ_CC = \
	...
	noah/noah.o \
	...
```
```
NS_TCL_LIB = \
	...
	tcl/mobility/noah.tcl \
	...
```
* Modify `wireless_phy.cc` &`wireless_phy.h` files 
Use `wireless_phy.cc` &`wireless_phy.h` files in `wireless-error-model.rar` to replace these files of `NS2`(`/home/lbs/ProgramFiles/ns-allinone-2.35/ns-2.35/mac`)
* Add `forwarder.cc` & `forwarder.h` files to `../ns-allinone-2.35/ns-2.35/mac`. And change `#include <iostream.h>` to `#include <iostream>` in `forwarder.cc` and `forwarder.h`
* Run `configure` & `make`
Change the directory to `/home/lbs/ProgramFiles/ns-allinone-2.35/ns-2.35` and run `configure` & `make` command
```
./configure --with-tcl-ver=8.5
sudo make clean 
sudo make
```
#### 4.18.3 Referenence
[1] [NS2无线网络遗失模型](http://www.cnblogs.com/this-543273659/archive/2013/05/06/3063024.html)
[2] [在ns2.35下完成柯老师lab18实验- Mr.Sting](http://www.ityuedu.com/article/2805458082/;jsessionid=2452218D3753BA7FFA12CC66067929A5)
###4.19 myEvalvid
###4.20 myEvalvid-NT
###4.21 图像传输效果分析与评估
###4.22 无线网络效果分析（一）：隐藏结点与暴露结点
###4.23 无线网络效果分析（二）：AdHoc网络路由协议效果分析
###4.24 无线网络效果分析（三）：802.11b DCF与802.11e EDCA的比较
###4.25 无线网络效果分析（四）：IEEE802.11b的吞吐量
###4.26 无线网络效果分析（五）：效果异常

## 反馈与建议
- 邮箱：<lbs1203940926@163.com>
- 微信：[@脱缰的哈士奇(ab1203940926)](http://ojx8u3g1z.bkt.clouddn.com/wechat-id.jpg)
- 微博：[@脱缰的哈士](http://weibo.com/2329754491/profile) 