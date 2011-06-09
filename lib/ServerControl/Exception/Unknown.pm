#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Exception::Unknown;

use strict;
use warnings;

use ServerControl::Exception;
use base qw(ServerControl::Exception);

sub new {
   my $that = shift;
   my $proto = ref($that) || $that;
   my $args = { @_ };
   my $self = $proto->SUPER::new(message => $args->{"message"});

   bless($self, $proto);

   return $self;
}

1;
