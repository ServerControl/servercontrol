use strict;
use warnings;

use Test::More tests => 5;

use_ok 'ServerControl';

my $conf = ServerControl->get_instance_conf("t/files/instance.conf");

ok($conf->{"name"} eq "test01", "strings");
ok($conf->{"path"} eq "/tmp/test01", "strings");
ok($conf->{"extension"}->[0] eq "Test1", "array");
ok($conf->{"extension"}->[1] eq "Test2", "array");


1;

