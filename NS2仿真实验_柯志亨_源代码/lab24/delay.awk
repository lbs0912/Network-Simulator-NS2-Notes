BEGIN {
	sum=0;
	no=0;
	max_delay=0.0;
}
{
	if($2!=1){
		sum+=$3;
		no++;
	}
	
	if($3 > max_delay)
		max_delay=$3;
}
END{
	printf("average delay:%f sec\n", (float)sum/no);
	printf("max delay:%f sec\n", max_delay);
}