set title "Performance anomaly (throughput)"
set xlabel "simulation time (sec)"
set ylabel "throughput (bps)"
plot "11m_cwmin" title "node B (11M)" with linespoints 3,"1m_cwmin" title "node A (11M -> 1M)" with linespoints 6
set terminal gif
set output "performance_anomaly3.gif"
replot
