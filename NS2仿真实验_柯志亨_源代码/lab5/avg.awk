BEGIN { FS = "\t"} {nl++} { s = s + $0} END { print "average:" s/nl }
