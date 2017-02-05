set title "Performance anomaly (throughput)"
set xlabel "simulation time (sec)"
set ylabel "throughput (bps)"
plot "11m_frame" title "node B (11M)" with linespoints 3,"1m_frame" title "node A (11M -> 1M)" with linespoints 6
set terminal gif
set output "performance_anomaly2.gif"
replot
