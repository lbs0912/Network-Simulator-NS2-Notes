#!/usr/bin/perl

#1.on-off每次增加的速率为100kbps
#2.固定的速率，执行实验次数为30次，且执行的结果会存到如result100等文件中
#3.若是要再做同样速率的实验室，记得先把resultXXXX文件删除

for($i = 100;$i <= 500;$i=$i+100) {
	for ($j = 1; $j <= 30;$j++) {
		system ("ns 5-1.tcl $i $j");
		$f1 = "data/out$i-$j.tr";
		$f2 = "data/result$i";
		system ("awk -f 5-1.awk $f1 >> $f2");
		print "\n"; 		
	}
	print "\n";
}
