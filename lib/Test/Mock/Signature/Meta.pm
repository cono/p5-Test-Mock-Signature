package Test::Mock::Signature::Meta;

use strict;
use warnings;

use Test::Mock::Signature::Dispatcher;

sub new {
    my ($class, %params) = @_;

    return bless(\%params, $class);
}

sub callback {
    my $self       = shift;
    my $callback   = shift;

    return $self->{'callback'} unless defined $callback;

    my $real_class = $self->{'class'};
    my $mock       = $real_class->_tms_mock_instance; # defined in import

    $self->{'callback'}  = $callback;

    my $dispatcher = $mock->dispatcher($self->{'method'});
    $dispatcher->add($self);
    $dispatcher->compile;
}

sub params {
    my $self = shift;

    return $self->{'params'};
}

42;
