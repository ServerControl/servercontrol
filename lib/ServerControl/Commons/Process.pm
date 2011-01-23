#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Commons::Process;

use strict;
use warnings;

require Exporter;

use base qw(Exporter);
use vars qw(@EXPORT);

@EXPORT = qw(spawn);

sub spawn {
   my ($exe) = @_;

   system($exe);
}

1;
