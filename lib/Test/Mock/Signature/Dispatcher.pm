package Test::Mock::Signature::Dispatcher;

use strict;
use warnings;

use Data::PatternCompare;

sub new {
    my $class  = shift;
    my $method = shift;

    my $params = {
        _method  => $method,
        _list    => [],
        _cmp     => Data::PatternCompare->new,
        _default => undef,
    };
    return bless($params, $class);
}

sub add {
    my $self = shift;
    my $meta = shift;
    my $list = $self->{'_list'};
    my $cmp  = $self->{'_cmp'};

    @$list = sort { $cmp->compare_pattern($a->params, $b->params) } @$list, $meta;
}

sub delete {
    my $self = shift;
    my $meta = shift;
    my $list = $self->{'_list'};
    my $cmp  = $self->{'_cmp'};

    @$list = grep { !$cmp->eq_pattern($_->params, $meta->params) } @$list;
}

sub compile {
    my $self = shift;
    return if defined $self->{'_default'};

    my $list = $self->{'_list'};
    my $cmp  = $self->{'_cmp'};

    $self->{'_default'} ||= do {
        no strict 'refs';

        *{$self->{'_method'}}{'CODE'}
    };
    my $default = $self->{'_default'};

    my $code = sub {
        my ($self, @params) = @_;

        for my $meta ( @$list ) {
            if ($cmp->pattern_match(\@params, $meta->params)) {
                my $cb = $meta->callback;

                goto &$cb;
            }
        }

        goto &$default;
    };

    no strict 'refs';
    no warnings 'redefine';
    *{$self->{'_method'}} = $code;
}

sub DESTROY {
    my $self   = shift;
    my $method = $self->{'_method'};

    no strict 'refs';
    no warnings 'redefine';
    *$method = $self->{'_default'};
}

42;
