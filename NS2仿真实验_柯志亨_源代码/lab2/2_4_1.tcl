set my_planet "earth"
if {$my_planet == "earth"} {
puts "I feel right at home."
} elseif {$my_planet == "venus"} {
   puts "This is not my home."
} else {
   puts "I am neither from Earth, nor from Venus."
}

set temp 95
if {$temp < 80} {
    puts "It's a little chilly."
} else {
    puts "Warm enough for me."
}
