set num_legs 4
switch $num_legs {
2 {puts "It could be a human."}
    4 {puts "It could be a cow."}
    6 {puts "It could be an ant."}
    8 {puts "It could be a spider."}
    default {puts "It could be anything."}
}
