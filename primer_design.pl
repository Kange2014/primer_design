#!/usr/bin/perl -w

use strict;

die "Usage: perl primer_design.pl <sequence_fasta_file> <output_file_name>\n" unless scalar @ARGV >= 2;

# design some primers.
# the output will be put into temp.out
use lib "/home/wangyj/BioPerl-1.6.901/";
use Bio::Perl;
use Primer::Design;

my $seqfile = shift @ARGV;
my $primer_file = shift @ARGV;

my @seq_array_ref = read_all_sequences("$seqfile","fasta");

open OUT,">$primer_file";
print OUT "ID,OLIGO,start,len,tm,gc%,any,3',seq\n";
foreach my $seq_ref(@seq_array_ref){
	next if($seq_ref->length() <= 100);
	my $primerobj; 
	eval{ $primerobj = Design->new(-seq => $seq_ref); };
	if($@){ print $seq_ref->display_id(),"\n";}
	
###################################################################################
# what are the arguments, and what do they mean?
# you can add following codes into this script to check them (just by deleting the "#"
# in the first of each line).
# 
 my $args = $primerobj->arguments;
 print "ARGUMENT\tMEANING\n";
 foreach my $key (keys %{$args}) {print "$key\t", $$args{$key}, "\n"}
#
###################################################################################

# if you hope to customize primer parameters, you can add any legal value to the package. 
# Please use $primer3->arguments to find a list of all the values that are allowed,
# or see the primer3 docs.
# 
# for example,
#
# set the number of designed primers
# $primerobj->add_targets(PRIMER_NUM_RETURN=>"20"); 

# set the region that primer product must cover
# If one or more targets is specified then a legal primer pair must flank at least one of them
# TRAGET: (interval list, default empty) Regions that must be included in the product. 
# The value should be a space-separated list of <start>,<length>     
# $primerobj->add_targets(TARGET => "400,100"); 

# set a sub-region of the given sequence to pick primers
# For example, often the first dozen or so bases of a sequence are vector, and should be excluded 
# from consideration. The value for this parameter has the form <start>,<length> where <start> is 
# the index of the first base to consider, and <length> is the number of subsequent bases in 
# the primer-picking region.
# $primerobj->add_targets(INCLUDED_REGION => "523988,900"); 
 
# set the maximum and minimum Tm of the primer
# $primerobj->add_targets(PRIMER_OPT_TM=>"55");
# $primerobj->add_targets(PRIMER_MIN_TM=>"50");
# $primerobj->add_targets(PRIMER_MAX_TM=>"60");
	
# set the range of primer product size
# $primerobj->add_targets(PRIMER_PRODUCT_SIZE_RANGE => "100-200");
	
# set the maximum and minimum size of the primer
# $primerobj->add_targets(PRIMER_OPT_SIZE=>"21");
# $primerobj->add_targets(PRIMER_MIN_SIZE=>"18");
# $primerobj->add_targets(PRIMER_MAX_SIZE=>"25");
	
#####################################################################################
# you can also change the program_name
# 
# $primerobj->program_name('my_suprefast_primer3');
 unless ($primerobj->executable) {
 	print STDERR "primer3 can not be found. Is it installed?\n";
 	exit(-1)
 }
#
# or change the primer3's path (default: /usr/bin/primer3_core): 
#
# $primerobj = Design->new(-seq => $seq_ref, -path => /home/usrname/primer3/primer3_core);
######################################################################################

	my $primer_info = $primerobj->run();
	print OUT $primer_info;
}
close OUT;
