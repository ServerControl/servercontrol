#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Schema;

use strict;
use warnings;

use Data::Dumper;
use ServerControl::Exception::Schema::ModuleNotFound;

sub get {
   my ($class, $key) = @_;

   no strict 'refs';

   my $v_db = (ref($class) || $class) . "::db";
   my $db   = $$v_db;

   use strict;

   return $db->{$key};
}

sub load_schema_module {
   my ($class) = @_;

   my $schema = ServerControl::Args->get->{'schema'};
   my $module = ServerControl::Args->get->{'module'};

   unless($schema && $module) {
      ServerControl->d_print("no schema or module given.\n");
      die("no schema or module given.");
   }

   my $class_name = "ServerControl::Schema::${schema}::$module";
   my $class_file_name = "ServerControl/Schema/$schema/$module.pm";

   ServerControl->d_print("class_name: $class_name\n");
   ServerControl->d_print("class_file_name: $class_file_name\n");

   eval {
      require $class_file_name;
      $class_name->import;

      no strict 'refs';
      my $db = (ref($class) || $class) . "::db";
      $$db = $class_name->get;
      use strict;
   };

   if($@) {
      die(ServerControl::Exception::Schema::ModuleNotFound->new);
   }
}

1;
