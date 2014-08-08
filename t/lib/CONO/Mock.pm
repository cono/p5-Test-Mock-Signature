package CONO::Mock;

use strict;
use warnings;

require Test::Mock::Signature;
our @ISA = qw(Test::Mock::Signature);

our $CLASS = 'CONO::Real';

sub init {
    my $self = shift;
    $self->{'init'} = 'done';
}

42;
