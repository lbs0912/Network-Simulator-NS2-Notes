set foo "lbs"
puts "My name is $foo"

set myarray(0) "zero"
set myarray(1) "two"
set myarray(2) "three"

for {set i 0} {$i < 3} {incr i 1} {
	puts $myarray($i)
}


set person_info(name) "Liu Baoshuai"
set person_info(age) "24"
set person_info(phone) "15821929853"

foreach thing [array names person_info] {
	puts "$thing = $person_info($thing)"
}


set f [open "/home/lbs/CodeWorkSpace/NS2/Lab1-TCL/myfile.txt" "w"]
puts $f "I am Liu Baoshuai"
puts $f "456"
close $f


puts $f "I am Liu Baoshuai"
puts $f "456"