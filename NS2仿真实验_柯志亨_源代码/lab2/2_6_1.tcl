set myarray(0) "Zero"
set myarray(1) "One"
set myarray(2) "Two"

for {set i 0} {$i < 3} {incr i 1} {
puts $myarray($i)
}
