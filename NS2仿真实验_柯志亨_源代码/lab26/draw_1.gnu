set title "Performance anomaly (throughput)"
set xlabel "simulation time (sec)"
set ylabel "throughput (bps)"
plot "11m" title "node B (11M)" with linespoints 3,"1m" title "node A (11M -> 1M)" with linespoints 6
set arrow from  16,350000 to 16,680000
set label "node A change to 1M" at 16,300000
set arrow from  30,350000 to 30,650000
set label "node A leave" at 30,300000
set label "Performance anomaly" at 18,1000000
set terminal gif
set output "performance_anomaly.gif"
replot
