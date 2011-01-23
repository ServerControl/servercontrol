#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl;

use strict;
use warnings;

use ServerControl::Args;
use ServerControl::Template;

use Data::Dumper;
use Getopt::Long qw(:config pass_through);

our $VERSION = '1.0.0';
our $MODULES = [];

sub run {
   my %opts;
   my @opts;

   my @ORIG_ARGV = @ARGV;

   GetOptions(ServerControl::Module::Base->get_options);

   ServerControl::Schema->load_schema_module;
   # ServerControl::Schema->get('httpd');
   
   my $mod       = ServerControl::Args->get->{'module'};
   my $mod_class = ServerControl::Module->load_module($mod);


   @ARGV = @ORIG_ARGV; # restore @ARGV for module parameter
   GetOptions($mod_class->get_options);

}

sub d_print {
   my ($class, $msg) = @_;
   print STDERR "[DEBUG] $msg";
}

1;
