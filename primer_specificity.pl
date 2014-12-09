#!/usr/bin/perl 

use strict;
use warnings;
use Carp;

die "Usage: perl primer_specificity.pl <primer_score_CSV_file> <database_file> <output_file_name>\n" unless scalar @ARGV >= 3;

############################################################################
# File:        primer_specificity.pl
# 
# Description: to make sure that primers are specific to other species. Here
#              we use BLAST with the identity of 70% and alignment
#              length of 15bp as a cutoff
# History:
# Created by Lulu Zheng, 07/16/2014
############################################################################

use Text::CSV;
use Primer::Specificity;

my $score_file = $ARGV[0];
my $database = $ARGV[1];
my $sp_file = $ARGV[2];

my ($line1,$line2,$primer1,$primer2,$score1,$score2);

if ( $^O =~ m{mswin}i ){                 # For Windows system
		system "del tmp.da*" if -e "tmp.dat";
		system "copy $database tmp.dat"; 
} 
else{ 
		system "rm tmp.da*" if -e "tmp.dat";
		system "cp \"$database\" tmp.dat";
}

my $csv = Text::CSV->new();
open (CSV, "<", "$score_file") or die $!;
open OUT,">$sp_file";
while (<CSV>) {
	$_ =~ s/\r\n/\n/ if /\r\n/;
	if ($. == 1){
		chomp;
		print OUT "$_,specificity (1/0)\n";
		next;
	}

	if ($csv->parse($_)) {
		my $line=$_;
  		my @columns = $csv->fields();
		chomp($line);
		
		
		$line1 = $line if ($.%2 == 0);   ######
		$line2 = $line if ($.%2 == 1);
			
		#my $threshold = 85;
		$primer1 = $columns[8] if ($.%2 == 0);
		$primer2 = $columns[8] if ($.%2 == 1);
		
		#$score1 = $columns[9] if ($.%2 == 0);
		#$score2 = $columns[9] if ($.%2 == 1);
				
		#####to judge whether primer pairs is specific
		if($.%2 == 1){
			#next if($score1 < $threshold || $score2 < $threshold);
				
			my $primer_obj = Specificity->new( 
									   left_primer => $primer1,
									   right_primer => $primer2, 
									   filename => "tmp.dat"
										);
			my ($spe_sign1,$spe_sign2) = $primer_obj->specific_marker();
			
			print OUT "$line1,$spe_sign1\n";
			print OUT "$line2,$spe_sign2\n";
		}
	}
}
close CSV;
close OUT;

if ( $^O =~ m{mswin}i ){                 # For Windows system
	system "del tmp.da*" if -e "tmp.dat";
	system "del blast.out" if -e "blast.out";
} 
else{ 
	system "rm tmp.da*" if -e "tmp.dat";
	system "rm blast.out" if -e "blast.out";
}
