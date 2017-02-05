BEGIN {FS="\t"}{ln++}{d=$0-t}{s2=s2+d*d} END \
{s=sqrt(s2/(ln-1)) ; print "sample variance: " s " \
Conf. Int. 95%: " t " +/- " 1.96*s/sqrt(ln)}
