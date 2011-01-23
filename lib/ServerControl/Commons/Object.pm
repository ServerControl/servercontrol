#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Commons::Object;

use strict;
use warnings;

sub has {
   my ($class, $what) = @_;

   my $pkg_name = ref($class) || $class;

   return $pkg_name->can($what)?1:0;
}

1;
