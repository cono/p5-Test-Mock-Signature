package Test::Mock::Signature;

use strict;
use warnings;

use Class::Load qw(load_class);

use Test::Mock::Signature::Meta;

our $VERSION = '0.01';
our @EXPORT_OK = qw(any);

sub any() {
    return $Data::PatternCompare::any;
}

sub init { }

sub new {
    my $class  = shift;
    my $singleton = do {
        no strict 'refs';
        ${$class .'::singleton'}
    };
    return $singleton if $singleton;

    my $params = {
        _real_class => do {
            no strict 'refs';
            ${$class .'::CLASS'}
        },
        _method_dispatcher => {},
    };

    $singleton = bless($params, $class);
    $singleton->init;

    return do {
        no strict 'refs';
        ${$class .'::singleton'} = $singleton;
    };
}

sub method {
    my $self   = shift;
    my $method = shift;
    my $class  = ref $self || $self;
    my $params = [ @_ ];

    return Test::Mock::Signature::Meta->new(
        class  => $self->{'_real_class'},
        method => $method,
        params => $params
    );
}

sub clear {
    my $self   = shift;
    my $method = shift;

    delete $self->{'_method_dispatcher'}->{$method};
}

sub dispatcher {
    my $self   = shift;
    my $method = shift;
    my $md     = $self->{'_method_dispatcher'};

    return $md->{$method} if exists $md->{$method};

    $md->{$method} = Test::Mock::Signature::Dispatcher->new($self->{'_real_class'} .'::'. $method);
}

sub import {
    my $class = shift;
    my $mock  = do {
        no strict 'refs';
        ${$class . '::CLASS'};
    };

    load_class($mock);

    my $caller = caller;
    my %export = map { $_ => 1 } @EXPORT_OK;

    no strict 'refs';
    no warnings 'redefine';

    *{$mock .'::_tms_mock_instance'} = sub {
        return $class->new;
    };

    for my $i ( @_ ) {
        next unless exists $export{$i};

        my $src_glob = __PACKAGE__  .'::'. $i;
        my $dst_glob = $caller .'::'. $i;

        *$dst_glob = *$src_glob;
    }
}

42;
