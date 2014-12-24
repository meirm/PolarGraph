perl -ne 'BEGIN{($rx,$ry)=splice (@ARGV,0,2);}chomp;@F=split(/\t/,$_);$F[0]-=$rx ; $F[1]+=$ry ;print "$F[0]\t$F[1]\n"' 281.0 250 a  > lines.txt 

