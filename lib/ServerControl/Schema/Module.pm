#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Schema::Module;

use strict;
use warnings;

sub register {
   my $class = shift;

   no strict 'refs';
   my $db = (ref($class) || $class) . "::db";
   $$db = { @_ };
}

sub get {
   my $class = shift;

   no strict 'refs';
   my $db = (ref($class) || $class) . "::db";
   return $$db;
}

1;
