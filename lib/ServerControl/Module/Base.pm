#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Module::Base;

use strict;
use warnings;

use ServerControl::FsLayout;
use ServerControl::Module;
use ServerControl::Extension;
use ServerControl::Exception::Schema::NotFound;

use base qw(ServerControl::Module);

use Data::Dumper;

__PACKAGE__->Parameter(
   help      => { isa => 'bool',   call => sub { shift; __PACKAGE__->help;               } },
   conf      => { isa => 'string', call => sub { shift; __PACKAGE__->conf(@_);           } },
   load      => { isa => 'string', call => sub { shift; __PACKAGE__->load(@_);           } },
   schema    => { isa => 'string', call => sub { shift; __PACKAGE__->load_schema(@_);    } },
   extension => { isa => 'array', call => sub { shift; __PACKAGE__->load_extension(@_); } },
   debug     => { isa => 'bool',   call => sub { $::debug = 1; } },
   "no-control-links"     => { isa => 'bool',   call => sub { } },
   "fs-layout"            => { isa => 'string',   call => sub { my $class = shift;
                                                                  unless(-f $_[0]) {
                                                                     ServerControl->d_print("File not found! $_[0]\n");
                                                                     die;
                                                                  }

                                                                  ServerControl->d_print("Loading YAML: $_[0]\n");

                                                                  eval {
                                                                     require YAML;
                                                                     my $s = eval { local(@ARGV, $/) = ($_[0]); <>; };
                                                                     my $tmp = YAML::Load($s);

                                                                     $tmp = __PACKAGE__->_parse_fslayout_options_recursive($tmp);
                                                                     ServerControl::FsLayout->set($tmp);
                                                                  };

                                                                  if($@) {
                                                                     die("Error loading YAML! $@");
                                                                  }

                                                               } },
);

sub help {
   my ($class) = @_;
   print "ServerControl - Version: " . $ServerControl::VERSION . "\n";
   print "\n";
   printf "  %-20s%s\n", "--help", "Display this help message";
   printf "  %-20s%s\n", "--module", "Load specified module";
   printf "  %-20s%s\n", "--schema", "Load specified schema";
   printf "  %-20s%s\n", "--extension", "Add a servercontrol extension to the instance";
   printf "  %-20s%s\n", "--debug", "Turn debug mode on";
   printf "  %-20s%s\n", "--no-control-links", "Only create a ,,control'' symlink. Do not create start, stop, ... links.";

   print "\n";
}

sub conf {
   my ($class, $conf) = @_;
   ServerControl->d_print("Conf: $conf\n");
}

sub load {
   my ($class, $load) = @_;
   ServerControl->d_print("Load: $load\n");
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
      ServerControl->d_print("$@\n");
      die (ServerControl::Exception::Schema::NotFound->new);
   }
}

sub load_extension {
   my ($class, $ext) = @_;

   my $ext_class = "ServerControl::Extension::$ext";
   my $ext_class_file = "ServerControl/Extension/$ext.pm";
   $ext_class_file =~ s/::/\//g;

   ServerControl->d_print("ext_class: $ext_class\n");
   ServerControl->d_print("ext_class_file: $ext_class_file\n");

   eval {
      require $ext_class_file;
      $ext_class->import;
   };

   if($@) {
      die ("$@\n");
   }
}

1;
