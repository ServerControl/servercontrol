#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Commons::FS;

use strict;
use warnings;

use Cwd qw(getcwd);
require Exporter;

use base qw(Exporter);
use vars qw(@EXPORT);

@EXPORT= qw(recursive_mkdir mkd 
            simple_chown 
            cat_file put_file);

sub recursive_mkdir {
   my ($dir, $mode) = @_;
   $mode ||= 0755;

   my @tupel = split(/\//, $dir);

   my $wd = getcwd;

   for my $t (@tupel) {
      $t ||= '/';

      mkd($t, $mode) unless(-d $t);

      chdir $t;
   }

   chdir($wd);
}

sub mkd {
   my ($dir, $mode) = @_;
   $mode ||= 0755;

   mkdir($dir, $mode) unless(-d $dir);
}

sub simple_chown {
   my ($user, $group, @list) = @_;

   my $uid = [ getpwnam($user)  ]->[2];
   my $gid = [ getgrnam($group) ]->[2];

   chown($uid, $gid, @list);
}

sub cat_file { 
   my $content = eval { local(@ARGV, $/) = (@_); <>; };

   my $BR= $/;
   if(wantarray) { return split(/$BR/, $content); }

   $content;
}

sub put_file {
   my ($file, $content) = @_;

   open(my $fh, ">", $file) or die($!);
   print $fh $content;
   close($fh);
}

1;
