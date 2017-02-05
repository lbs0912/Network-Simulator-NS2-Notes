#!/bin/bash  
  
gnuplot -persist<<EOF  
  
set terminal gif  
set output "throughput.gif"  
set title "throughput"  
set xlabel "on-off flow rate/kbps"  
set ylabel "s1-d1 throughput/kbps"  
set xrange [0:600]  
set xtics 0,100,600  
unset key  
  
plot "cbr_jitter" using 1:2:3 with errorbars, "result.txt" with linespoints  
  
EOF  
