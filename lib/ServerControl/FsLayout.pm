#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::FsLayout;

use strict;
use warnings;

use vars qw($LAYOUT);

sub get {
   return $LAYOUT || {};
}

sub get_file {
   my ($class, $section, $key) = @_;

   return $LAYOUT->{"Files"}->{$section}->{$key}->{"name"};
}

sub get_directory {
   my ($class, $section, $key) = @_;

   return $LAYOUT->{"Directories"}->{$section}->{$key}->{"name"};
}

sub set {
   $LAYOUT = pop;
}

1;
