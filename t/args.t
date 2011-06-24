use strict;
use warnings;

use Test::More tests => 3;

use_ok 'ServerControl::Args';

@ARGV = ("--help", "--module=test");

ServerControl::Args->import;

my $args = ServerControl::Args->get;

ok(defined $args->{"help"}, "boolean argument");
ok($args->{"module"} eq "test", "string argument");


1;

