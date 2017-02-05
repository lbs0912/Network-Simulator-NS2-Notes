set  rng  [new RNG]
$rng  seed 1

puts  "Testing Pareto Distribution"
set  r1  [new RandomVariable/Pareto]
$r1  use-rng   $rng
$r1  set  avg_  10.0
$r1  set  shape_  1.2
for {set i 1} {$i <=3} {incr i} { 
   puts [$r1 value]
}

puts  "Testing Constant Distribution"
set  r2  [new RandomVariable/Constant]
$r2  use-rng  $rng
$r2  set avg_ 5.0
for {set i 1} {$i <=3} {incr i} { 
   puts [$r2 value]
}

puts  "Testing Uniform Distribution"
set  r3  [new RandomVariable/Uniform]
$r3  use-rng $rng
$r3  set  min_ 0.0
$r3  set  max_ 10.0
for {set i 1} {$i <=3} {incr i} { 
   puts [$r3 value]
}

puts  "Testing Exponential Distribution"
set  r4 [new RandomVariable/Exponential]
$r4  use-rng $rng
$r4  set avg_ 5
for {set i 1} {$i <=3} {incr i} { 
   puts [$r4 value]
}

puts  "Testing HyperExponential Distribution"
set  r5  [new RandomVariable/HyperExponential]
$r5  use-rng  $rng
$r5  set  avg_  1.0
$r5  set  cov_  4.0
for {set i 1} {$i <=3} {incr i} { 
   puts [$r5 value]
}
