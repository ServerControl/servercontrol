#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Module::PidFile;

use strict;
use warnings;

require Exporter;
use base qw(Exporter);
use vars qw(@EXPORT);

@EXPORT = qw(stop status);

sub stop {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);
   my $pid_file = "$path/run/$name.pid";
   my $pid = eval { local(@ARGV, $/) = ($pid_file); <>; };
   chomp $pid;

   kill 15, $pid;
}

sub status {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);
   my $pid_file = "$path/run/$name.pid";
   if(-f $pid_file) { return 1; }
}

1;
