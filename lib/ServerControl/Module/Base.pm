#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Module::Base;

use strict;
use warnings;

use ServerControl::Module;
use ServerControl::Exception::Schema::NotFound;

use base qw(ServerControl::Module);

use Data::Dumper;

__PACKAGE__->Parameter(
   help   => { isa => 'bool', call => sub { __PACKAGE__->help; } },
   conf   => { isa => 'string', call => sub { shift; __PACKAGE__->conf(@_); } },
   load   => { isa => 'string', call => sub { shift; __PACKAGE__->load(@_); } },
   schema => { isa => 'string', call => sub { shift; __PACKAGE__->load_schema(@_); } }
);

sub help {
   my ($class) = @_;
   print "Help\n";
}

sub conf {
   my ($class, $conf) = @_;
   print "Conf: $conf\n";
}

sub load {
   my ($class, $load) = @_;
   print "Load: $load\n";
}

sub load_schema {
   my ($class, $schema) = @_;
   my $schema_class = "ServerControl::Schema::$schema";
   my $schema_class_file = "ServerControl/Schema/$schema.pm";

   ServerControl->d_print("schema_class: $schema_class\n");
   ServerControl->d_print("schema_class_file: $schema_class_file\n");

   eval {
      require $schema_class_file;
      $schema_class->import;
   };

   if($@) {
      print "$@\n";
      die (ServerControl::Exception::Schema::NotFound->new);
   }
}

1;
