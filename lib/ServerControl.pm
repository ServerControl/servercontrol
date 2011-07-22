#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl;

use strict;
use warnings;

require ServerControl::Args;
use ServerControl::FsLayout;
use ServerControl::Template;
use ServerControl::Commons::FS;
use ServerControl::Schema;
use ServerControl::Extension;

use Data::Dumper;
use Getopt::Long qw(:config pass_through);
use File::Basename qw(dirname);
use FindBin;

our $VERSION = '0.100';
our $MODULES = [];

$::debug = 0;

sub run {
   my ($class) = @_;
   my %opts;
   my @opts;

   my @ORIG_ARGV = @ARGV;

   my $exec_path = $FindBin::Bin;
   if( -f "$exec_path/.instance.conf") {
      # wenn in einer instanz, dann ServerControl::ctrl ausfuehren
      # um die instanz zu verwalten.
      $class->ctrl($exec_path);
   }
   else {
      ServerControl::Args->import;
   }
 
   # try to load schema
   eval {
      ServerControl::Schema->load_schema_module;
   };

   GetOptions(ServerControl::Module::Base->get_options);
  
   my $mod       = ServerControl::Args->get->{'module'};
   my $mod_class;
   if($mod) {
      $mod_class = ServerControl::Module->load_module($mod);
   }

   @ARGV = (@ARGV, @ORIG_ARGV);

   UNIQ: {
      my %u;
      @u{@ARGV} = 1;
      @ARGV = keys %u;
   };

   MODULE: {
      local $SIG{'__WARN__'} = sub {
         require Devel::StackTrace;
         my $trace = Devel::StackTrace->new;
         ServerControl->d_print($trace->as_string);

         die(ServerControl::Exception::Unknown->new(message => $_[0]));
      };
      if($mod_class) {
         GetOptions($mod_class->get_options);
      }
   }

}

sub ctrl {
   my ($class, $dir) = @_;
   my $conf = $class->get_instance_conf("$dir/.instance.conf");

   for my $key (keys %{$conf}) {
      if(ref($conf->{$key}) eq "ARRAY") {
         for my $ext (@{$conf->{$key}}) {
            push(@ARGV, "--$key" . "=$ext");
         }
      } 
      else {
         push(@ARGV, "--$key" . ($conf->{$key} ne "1"?"=".$conf->{$key}:""));
      }
   }

   my $call = [ split(/\//, $0) ]->[-1];
   unless($call eq "control") {
      push(@ARGV, "--$call");
   }

   ServerControl::Args->import;
}

sub get_instance_conf {
   my ($class, $file) = @_;
   
   my $conf = {};
   my @content = cat_file($file);
   for my $line (@content) {
      my($key, $val) = ($line =~ m/^(.*?)=(.*)$/);
      if($key =~ m/^\@/) {
         my $tmpkey = substr($key, 1);
         $conf->{$tmpkey} = [ split(/,/, $val) ];
      } 
      else {
         $conf->{$key} = $val;
      }
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
