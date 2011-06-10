#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Template;

use strict;
use warnings;

use File::Basename qw(dirname basename);
use ServerControl::Commons::FS;

sub parse {
   my ($class, $dest_file, $source_file, $data) = @_;

   $source_file ||= ServerControl::Args->get->{'template'};
   $data        ||= ServerControl::Args->get;

   $data->{'instance_path'} = ServerControl::Args->get->{'path'};

   # wenn $dest_file && $source_file ein verzeichnis ist, dann das ganze verzeichnis als template verwenden
   if(-d $source_file) {
      my $to_dir = dirname($dest_file);
      my @dirs = ($source_file);
      my $base_dir = $source_file;
      for my $dir (@dirs) {
         opendir(my $dh, $dir) or die($!);

         while( my $entry = readdir($dh) ) {
            next if($entry =~ m/^\./);
            if(-d "$dir/$entry") {
               push(@dirs, "$dir/$entry");
               next;
            }

            my $new_dir = $dir;
            $new_dir =~ s/^$base_dir//;

            unless(-d "$to_dir$new_dir") {
               recursive_mkdir($to_dir . $new_dir);
            }

            my $new_file = basename("$dir/$entry");
            $class->parse("$to_dir$new_dir/$new_file", "$dir/$entry", $data);
         }

         closedir($dh);
      }

      exit;
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
