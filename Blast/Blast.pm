package Blast;

use strict;
use warnings;

use Bio::Tools::Run::StandAloneBlast;
use Bio::Seq;
use Bio::AlignIO;

sub new{
	my ($class,%arg) = @_;
	my $self = bless{
		_seq => $arg{seq},
		_program => $arg{program} || 'blastn',
		_database => $arg{database},
		_outfile => 'blast.out',
		_F => $arg{F} || 'T',
		_q => $arg{q} || '-3',
	},$class;
	return $self;
}

sub _formatdb{
	my ($self) = @_;
	my $formatdb_file = $self->{_database}.".nsd";
	system "formatdb -i $self->{_database} -p F -o T" unless(-e $formatdb_file);
}

sub blast{
	my($self) = @_;
	
	$self->_formatdb();
	
	my $local_blast = Bio::Tools::Run::StandAloneBlast->new(
         								-program => $self->{_program},
         								-database => $self->{_database},
										-q => $self->{_q},
         								_READMETHOD => "Blast");
	$local_blast->outfile($self->{_outfile});
	$local_blast->F($self->{_F});         #####low complexity filtering
	
	my ($blast_report,$seq);
	if( ref($self->{_seq}) eq 'Bio::Seq' ){
		$blast_report = $local_blast->blastall($self->{_seq}); 
	}else{
		$seq = Bio::Seq->new(-id => "query1",-seq => $self->{_seq} );
		#$seq=$seq->revcom();
		$blast_report = $local_blast->blastall( $seq ); 
	}
	my $result = $blast_report->next_result;

	return($result);
}

1;
