use strict;
use warnings;

use Test::More;
use FindBin qw($Bin);
use File::Spec;

use lib File::Spec->catdir($Bin, 'lib');

use CONO::Mock qw| any |;

ok(any, 'any exported');

my $mock = CONO::Mock->new;
is($mock->{'init'}, 'done', 'init call in constructor');

done_testing;
