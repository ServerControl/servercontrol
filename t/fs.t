use strict;
use warnings;

use Test::More tests => 3;

use_ok 'ServerControl::Commons::FS';

ServerControl::Commons::FS->import;

mkd("t/tmp");
ok(-d "t/tmp", "mkd");

rmdir "t/tmp";

recursive_mkdir("t/tmp/a/b/c");
ok(-d "t/tmp/a/b/c", "recursive_mkdir");

rmdir "t/tmp/a/b/c";
rmdir "t/tmp/a/b";
rmdir "t/tmp/a";
rmdir "t/tmp";

#open(my $f, ">", "t/test.txt") or die($!);
#print $f "\n";
#close($f);

# 4, 5
#my @stats = stat "t/test.txt";
#my $uid = [ getpwnam("nobody")  ]->[2];
#my $gid = [ getgrnam("nogroup") ]->[2];
#if(!$gid) {
#   $gid = [ getgrnam("nobody") ]->[2];
#}

#simple_chown("nobody", "nogroup", "t/test.txt");

#ok($stats[4] == $uid, "stats user");
#ok($stats[5] == $gid, "stats group");


1;

