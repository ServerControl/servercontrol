use strict;
use warnings;

use Test::More tests => 3;
use Data::Dumper;

use_ok 'ServerControl::Extension';

ServerControl::Extension->register("test", sub {return 1;});

my $hooks = ServerControl::Extension->get("test");

ok(scalar(@$hooks) > 0, "register extension");

my $code = $hooks->[0]->{"code"};
ok(&$code() == 1, "callback");


1;

