#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Extension;

use strict;
use warnings;

use vars qw($EXTENSIONS);

sub register {
   my ($class, $hook, $sub) = @_;
   if(! defined $EXTENSIONS->{$hook}) { $EXTENSIONS->{$hook} = []; }
   push(@{$EXTENSIONS->{$hook}}, $sub);
}

sub get {
   my ($class, $hook) = @_;
   return $EXTENSIONS->{$hook};
}

1;
