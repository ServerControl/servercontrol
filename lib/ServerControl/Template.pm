#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Template;

use strict;
use warnings;

use ServerControl::Commons::FS;

sub parse {
   my ($class, $dest_file, $source_file, $data) = @_;

   $source_file ||= ServerControl::Args->get->{'template'};
   $data        ||= ServerControl::Args->get;

   $data->{'instance_path'} = ServerControl::Args->get->{'path'};

   # wenn $dest_file && $source_file ein verzeichnis ist, dann das ganze verzeichnis als template verwenden
   if(-d $dest_file && -d $source_file) {
      die("To be implemented... soon...");
   } else {
      my $t_content = cat_file($source_file);
      for my $key (keys %{$data}) {
         my $val = $data->{$key};
         $t_content =~ s/\@$key\@/$val/gms;
      }

      put_file($dest_file, $t_content);
   }
}

1;
