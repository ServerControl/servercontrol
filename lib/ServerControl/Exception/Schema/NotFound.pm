#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Exception::Schema::NotFound;

use strict;
use warnings;

use ServerControl::Exception;
use base qw(ServerControl::Exception);

sub new {
   my $that = shift;
   my $proto = ref($that) || $that;
   my $self = $proto->SUPER::new(message => 'Schema not found.');

   bless($self, $proto);

   return $self;
}

1;
