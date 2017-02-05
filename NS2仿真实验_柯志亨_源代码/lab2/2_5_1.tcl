proc sum_proc {a b} {
return [expr $a + $b]
}

proc magnitude {num} {
if {$num > 0} {
return $num
} 

set num [expr $num * (-1)]
return $num
}

set num1 12
set num2 14
set sum [sum_proc $num1 $num2]

puts "The sum is $sum"
puts "The magnitude of 3 is [magnitude 3]"
puts "The magnitude of -2 is [magnitude -2]"
