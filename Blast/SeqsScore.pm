package SeqsScore;

use strict;
use warnings;

use Carp;
use Bio::AlignIO;
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

sub new{
	my($class,%arg) = @_;
	my $self = bless{
		_hash => $arg{hash},
	}, $class;
	
	$class->_incr_count();
	return $self;
}

sub score{
	my ($self) = @_;
	
	my $str = ref($self->{_hash});
	unless($str eq 'HASH'){ croak "The constructor method's argument must be a reference to a hash!"; }
	
	my @seq=keys %{$self->{_hash}};                                                              #####keys(sequences)
	my @count=values %{$self->{_hash}};                                                          #####values(numbers)
	
	my $length=0;
	$length += $_ foreach(@count); #####the number of sequences
	
	my $identity = 0;
	for(my $i=0;$i<@seq-1;$i++){
		for(my $j=$i+1;$j<@seq;$j++){
			if($seq[$j]=~/^N+$/ || $seq[$i]=~/^N+$/){ $identity += 0;}                             #######why is the identity 1 when some sequence is "NNNNNNN..." ?
			else{
				my $bl2seq_obj = Bl2seq->new(seq_input1 => $seq[$i],seq_input2 => $seq[$j]);    #######?????Bl2seq, why not Blast::Bl2seq???
				$identity += $bl2seq_obj->identity()*($count[$i])*($count[$j]);			
			}								
		}
		$identity+=100*($count[$i]*($count[$i]-1)/2);                           #####if the sequence is the same ,their identities is 100	
	}
	$identity+=100*($count[@seq-1]*($count[@seq-1]-1)/2);                     	##### for the last sequences, which are also the same
		
	my $score;
	$score=$identity*2/($length*($length-1)) unless($length==1);
	$score=100 if($length==1);
	
	return $score;
}

# When an object is no longer being used, this will be automatically called
# and will adjust the count of existing objects
sub DESTROY {
    my($self) = @_;
    $self->_decr_count();
}

1;
				