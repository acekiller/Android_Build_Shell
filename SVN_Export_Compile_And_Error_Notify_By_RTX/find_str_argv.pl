#!/usr/bin/perl
#
#

use warnings;
 
if(@ARGV > 0){
	my $str = $ARGV[0];
	my $dir = ".";

	if(scalar(@ARGV) > 1 && -d $ARGV[1]){
		$dir = $ARGV[1];
	}

	findstr($dir, $str);
}
else{
	print("usage: suren str dir.\n");
}


sub findstr{
	my $file = $_[0];
	my $str = $_[1];

	if(-f $file){
		my $FILE;
		open($FILE, $file);
	
		while(<$FILE>){
			#if(/$str/){
			if (/^make.*:.*\[(.*)\].*$/){
				print("$file : $_");
			}
		}
		
	}elsif(-d $file){
		my $DIR;
		my $dir;
		opendir($DIR, $file);
	
		while($dir = readdir($DIR)){
			if($dir ne ".." && $dir ne "."){
				findstr("$file/$dir", $str);
			}
		}

		closedir($DIR);
	}
}
