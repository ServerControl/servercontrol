#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Args;

use strict;
use warnings;

use Data::Dumper;

use vars qw($ARGS);

sub get {
   return $ARGS || {};
}

sub set {
   $ARGS = pop;
}

sub import {
   foreach my $o (@ARGV) {
      my($key, $val) = ($o =~ m/^--(.*?)=(.*)$/);
      if($key && $val) {
         $ARGS->{$key} = $val;
      } else
      {
         $o =~ m/^--(.*?)$/;
         $ARGS->{$1} = 1;
      }
   }
}

1;
