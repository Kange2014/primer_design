
package Bl2seq;

use strict;
use warnings;

use Bio::Tools::Run::StandAloneBlast;
use Bio::Seq;
use Bio::AlignIO;

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
		_seq_input1 => $arg{seq_input1},
		_seq_input2 => $arg{seq_input2},
		_program => $arg{program} ||'blastn',
		_q => $arg{q} || '-1',
	},$class;
	
	$class->_incr_count();
	return $self;
}

###make a bl2seq
sub hsp{
	 my ($self)=@_;
	 my $factory = Bio::Tools::Run::StandAloneBlast->new(-program => $self->{_program},-outfile => "bl2seq.out",-q=> $self->{_q});
	 my ($input1,$input2);
	 if(ref($self->{_seq_input1}) eq 'Bio::Seq'){
		$input1 = $self->{_seq_input1};
	}else{
		$input1=Bio::Seq->new(-id => "query1",-seq => $self->{_seq_input1});
	}
	if(ref($self->{_seq_input2}) eq 'Bio::Seq'){
		$input2 = $self->{_seq_input2};
	}else{
		$input2=Bio::Seq->new(-id => "query2",-seq => $self->{_seq_input2});
	}
    	my $bl2seq_result = $factory->bl2seq($input1,$input2);
	while(my $result = $bl2seq_result->next_result){
		while(my $hit = $result->next_hit){
			while (my $hsp = $hit->next_hsp){
				return $hsp;
				last;
			}
			last;
		}
		last;
	}
      
}

sub identity{
	my ($self) = @_;
	
	my $hsp = $self->hsp();
	if($hsp) {$hsp->percent_identity;}
	else{ 0; }
}

sub pos{
	 my ($self) = @_;
	 
	 my $hsp = $self->hsp();
     if($hsp) {
		return ($hsp->start('hit'),$hsp->end('hit'));
     }
     else { return(0,0); }                          
}

# When an object is no longer being used, this will be automatically called
# and will adjust the count of existing objects
sub DESTROY {
    my($self) = @_;
    $self->_decr_count();
}

1;
