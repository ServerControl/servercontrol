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
use ServerControl::Commons::FS;
use ServerControl::Schema;
use ServerControl::Extension;

use Data::Dumper;
use Getopt::Long qw(:config pass_through);
use File::Basename qw(dirname);
use FindBin;

our $VERSION = '0.92';
our $MODULES = [];

$::debug = 0;

sub run {
   my ($class) = @_;
   my %opts;
   my @opts;

   my $exec_path = $FindBin::Bin;
   if( -f "$exec_path/conf/instance.conf") {
      # wenn in einer instanz, dann ServerControl::ctrl ausfuehren
      # um die instanz zu verwalten.
      $class->ctrl($exec_path);
   }

   my @ORIG_ARGV = @ARGV;

   GetOptions(ServerControl::Module::Base->get_options);

   ServerControl::Schema->load_schema_module;
   # ServerControl::Schema->get('httpd');
   
   my $mod       = ServerControl::Args->get->{'module'};
   my $mod_class = ServerControl::Module->load_module($mod);


   @ARGV = @ORIG_ARGV; # restore @ARGV for module parameter
   GetOptions($mod_class->get_options);

}

sub ctrl {
   my ($class, $dir) = @_;
   my $conf = $class->get_instance_conf("$dir/conf/instance.conf");

   for my $key (keys %{$conf}) {
      if($key =~ m/^\@/) {
         my $tmpkey = substr($key, 1);
         for my $tmpval (split(/,/, @{$conf->{$key}})) {
            $tmpval =~ s/\s+//g;
            push(@ARGV, "--$tmpkey" . "=$tmpval");
         }
      } 
      else {
         push(@ARGV, "--$key" . ($conf->{$key} ne "1"?"=".$conf->{$key}:""));
      }
   }

   my $call = [ split(/\//, $0) ]->[-1];
   push(@ARGV, "--$call");

   ServerControl::Args->import;
}

sub get_instance_conf {
   my ($class, $file) = @_;
   
   my $conf = {};
   my @content = cat_file($file);
   for my $line (@content) {
      my($key, $val) = ($line =~ m/^(.*?)=(.*)$/);
      $conf->{$key} = $val;
   }

   $conf;
}

sub d_print {
   my ($class, $msg) = @_;

   if($::debug) {
      print STDERR "[DEBUG] $msg";
   }
}

1;
