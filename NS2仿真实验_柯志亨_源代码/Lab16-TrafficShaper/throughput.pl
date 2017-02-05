#!/usr/bin/perl
$infile=$ARGV[0];
$flowid=$ARGV[1];
$granularity=$ARGV[2];

$sum=0;
$clock=0;

open(DATA,"<$infile")
||die "Can't open $infile $!";
while(<DATA>) {
@x=split(' ');
if($x[1]-$clock<=$granularity)
{
if($x[0]eq'r')
{ 
if($x[7]eq $flowid)
{
$sum=$sum+$x[5];

}

}

}

else
{
$throughput=$sum*8.0/$granularity;
print STDOUT "$x[1]:$throughput bps\n";
$clock=$clock+$granularity;
$sum=0;

}  
}
$throughput=$sum*8.0/$granularity;
print STDOUT "$x[1]:$throughput bps\n";
$clock=$clock+$granularity;
$sum=0;

close DATA;
exit(0);