proc dumb_proc {} {
set myvar 4
    puts "The value of the local variable is $myvar"
    global myglobalvar
    puts "The value of the global variable is $myglobalvar"
}

set myglobalvar 79
dumb_proc
