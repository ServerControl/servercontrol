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

   no strict 'refs';
   my $class_syms = \%{(ref($class) || $class) . '::'};
   use strict;

   return exists $class_syms->{$what};
}

1;
