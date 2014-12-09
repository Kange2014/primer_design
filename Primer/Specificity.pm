package Specificity;

use warnings;
use strict;
use Carp;

use Blast::Blast;
use Blast::Bl2seq;

{
	# Global variable to keep count of existing objects
    my $_count = 0;
	# Manage the count of existing objects
    sub get_count {
        $_count;
    }
    sub _incr_count {
        ++$_count;
    }
    sub _decr_count {
        --$_count;
    }

}


sub new {
	my ($class,%arg) = @_;
	my $self = bless {
		_left_primer => $arg{left_primer},
		_right_primer => $arg{right_primer},
		_filename => $arg{filename}
	},$class;
	$class->_incr_count();
	return $self;
}

sub specific_marker{
	my ($self) = @_;
	
	my $spe_sign1 = 1;        ###### used to judge whether primer pairs is specific to the certain species
	my $spe_sign2 = 1;
	#my $uni_sign = 0;        ###### used to judge whether primer pairs is universal to the certain genus
	#my $score1 = 0;
	#my $score2 = 0;
	
	
			
	#my $database = $self->{_filename};
	#my $str = Bio::SeqIO->new(-file=> $database, -format => 'Fasta');
	#my @seq_array=();
	#while ( my $seq = $str->next_seq() ) {push (@seq_array, $seq) ;}
			
	#my ($hit_len,$max_identity,$start,$end) = (0,0,0,0);
	my ($hit_len,$max_identity) = (0,0);
	my $hsp;
		
	#######for the left primer
	my $blast_obj = Blast->new( seq => $self->{_left_primer},database => $self->{_filename});
	my $result = $blast_obj->blast();
	if($result->num_hits() == 0){
		;
	}
	else{
			while(my $hit = $result->next_hit()){
				while($hsp=$hit->next_hsp){
					$max_identity = $hsp->percent_identity();
					$hit_len = $hsp->length('hit');
					last;
				}
				last;
			}
			###print $max_identity." ,".$hit_len."\n";
			if($max_identity < 70 || $hit_len < 15){                                             #######if the best sequence's identity is less than 70 or the hit length is less than 15, then give up...	
				;
			}
			else{ $spe_sign1 = 0; }
			
			#($start,$end) = ($hsp->start('hit'),$hsp->end('hit'));
			#my $hit_string = $hsp->hit_string();	
			#my $primer_hash = $self->_map($hit_string,$start,$end,\@seq_array);
			#my $seqs_score_object = SeqsScore->new( hash => $primer_hash ); 
			#$score1 = $seqs_score_object->score();
	}		
			#########for the right primer
	my $seq_temp=Bio::Seq->new(-id => "query",-seq => $self->{_right_primer});
	$seq_temp=$seq_temp->revcom();
	$blast_obj = Blast->new( seq => $seq_temp,database => "tmp.dat");
	$result = $blast_obj->blast();
	if($result->num_hits() == 0){
		;
	}
	else{
		while(my $hit = $result->next_hit()){
				while($hsp=$hit->next_hsp){
					$max_identity = $hsp->percent_identity();
					$hit_len = $hsp->length('hit');
					last;
				}
				last;
			}
			if($max_identity < 70 || $hit_len < 15){                                            #######if the best sequence's identity is less than 70 or the hit length is less than 15, then give up...	
				;
			}
			else{ $spe_sign2 = 0; }
			#($start,$end) = ($hsp->start('hit'),$hsp->end('hit'));
			#$hit_string = $hsp->hit_string();		
			#$primer_hash = $self->_map($hit_string,$start,$end,\@seq_array);
			#$seqs_score_object = SeqsScore->new( hash => $primer_hash ); 
			#$score2 = $seqs_score_object->score();
									
			#$spe_sign++;	 ###### if there exists sequence(s) whose identities to left and right primers are both more than 70, then the primer pair can be a  candidate of universe primer pairs  		
			
			#print "$score1,$score2\n";	
			
			#my $threshold2 = 70; ###($self->{_genus} =~ /influenza a virus/i)? 70:70;   ######70 for FluA, 70 for others
			#if($score1 >= $threshold2 && $score2 >= $threshold2){
			#	$uni_sign++;	##### if the candidate universe primer pair is conserved, it can be considered as a universe primer pair					
			#	$self->{_left_score}->[$i] = $score1;
			#	$self->{_right_score}->[$i] = $score2;
			#}
	}
	
	return ($spe_sign1,$spe_sign2);
}

sub DESTROY {
    my($self) = @_;
    $self->_decr_count();
}

1;




