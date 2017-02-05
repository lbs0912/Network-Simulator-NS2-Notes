#!/usr/bin/perl

#1.on-off每次增加的速率為100kbps
#2.固定的速率,執行實驗次數為30次,且執行的結果會存到如result100, result200,...等檔案中
#3.若是要再做同樣速率實驗時,請記得先把resultXXX的檔案刪如

for ($i = 100; $i <=500 ; $i=$i+100) {
    for ($j = 1; $j <= 30; $j++) {
	system("ns lab5.tcl $i $j");
	$f1="out$i-$j.tr";
	$f2="result$i";
	system("awk -f 5T.awk $f1 >> $f2");
	print "\n";
    }
    print "\n";
}
