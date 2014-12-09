#!/usr/bin/perl
    
use strict;
use warnings;

die "Usage: perl primer_score.pl <primer_CSV_file> <database_file> <output_file_name>\n" unless scalar @ARGV >= 3;
############################################################################
# File:        primer_score.pl
# 
# Description: Primers are aligned to every sequence in the big sample by blastall
#              to get the correspoding regions and then calculated scores.
#              
# History:
# Created by Lulu Zheng, 10/14/2010
# Modified by Lulu Zheng, 08/27/2013
############################################################################

use lib "/home/wangyj/BioPerl-1.6.901/";
use Text::CSV;
use File::Copy;
use Bio::Perl;
use Bio::Tools::Run::StandAloneBlast;
use Bio::AlignIO;
use Bio::Seq;
use Blast::Bl2seq;
use Blast::SeqsScore;

my $primer_file = $ARGV[0];
my $database = $ARGV[1];
my $score_file = $ARGV[2];

my $seq_obj = Bio::Seq->new(-id => "query1",-seq => "aaact");

if($database =~ /\s/){
	my $temp = $database;
	$temp =~ s/\s+/\_/g;
	#if ( $^O =~ m{mswin}i ){ system "ren $database $temp"; print "Hello\n"; } # For Windows system
	#else{ system "mv $database $temp"; }
	rename($database, $temp);
	$database =~ s/\s+/\_/g;
}
#my $formatdb_file = $database.".nsq";
#system "formatdb -i $database -p F" unless(-e $formatdb_file);
system "formatdb -i $database -p F";
my $local_blast = Bio::Tools::Run::StandAloneBlast->new(
											-program => 'blastn',
											-database =>$database,
											###		-q => '-1',
											_READMETHOD => "Blast");
$local_blast->outfile("blast.out");
$local_blast->F('F');
$local_blast->b('1000000');
$local_blast->v('1000000');
		
my $csv = Text::CSV->new();
open (CSV, "<", "$primer_file") or die $!;
open OUT,">$score_file";
while (<CSV>) {
	$_ =~ s/\r\n/\n/ if /\r\n/;
	if ($. == 1){
		chomp;
		print OUT "$_,score\n" unless -s "$score_file";
		next;
	}

	if ($csv->parse($_)) {
		my $line=$_;
  		my @columns = $csv->fields();
  	
		my $primer = $columns[8];
		my $primer_len = length($primer);

		my %primer_samples=();
		$seq_obj->seq($primer);
		$seq_obj->display_id($columns[0]);
		my $blast_report = $local_blast->blastall($seq_obj); 
		my $result = $blast_report->next_result;
		next if $result->num_hits() == 0;
		while(my $hit = $result->next_hit()){
			my $hsp = $hit->next_hsp;
			unless ($hsp){
				#print $hit->accession."\n";
				print OUT "$line, \n";
				next ;
			}
			my ($start,$end) = ($hsp->start('hit'),$hsp->end('hit'));
			if($end-$start+1 >= $primer_len-2){
				my $string = $hsp->hit_string();
				$string =~ s/\-//g;
				if(exists $primer_samples{$string}) { $primer_samples{$string} += 1; }
				else { $primer_samples{$string} = 1; }
			}
		}
		my $score = 0;
		
		my $count = 0;
		$count += $_ foreach(values %primer_samples);
		
		my @primer_array = keys %primer_samples;
		my $count2 = @primer_array;
		
		
		if($count > 300){
			my %temp;
			my $k = 0;
			for(my $i = 0; $i< $count2;$i++){
				for(my $j = 0; $j < $primer_samples{$primer_array[$i]}; $j++){
					$temp{$k} = $primer_array[$i];
					$k++;
				}
			}
			
			foreach (1..3){
				my $num=0;
				my %rands=();
				while(1){    	
					my $no=int(rand($count));
					if(!$rands{$no}){ $rands{$no}=1; $num++; }
					last if($num >= 100);
				}
				my %rand_primers = ();
				foreach my $i(keys %rands){
					if(exists $rand_primers{$temp{$i}} ){ $rand_primers{$temp{$i}} += 1; }
					else{ $rand_primers{$temp{$i}} = 1; }
				}
				my $scoreobj = SeqsScore->new( hash => \%rand_primers);
				$score += $scoreobj->score();
			}
			$score = $score/3;
		}
		else{
			my $scoreobj = SeqsScore->new( hash => \%primer_samples);
			$score = $scoreobj->score();
		}
  		chomp($line);
  		print OUT "$line,$score\n"; 
  	}
}
close CSV;
close OUT;
