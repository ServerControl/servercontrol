#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Module;

use strict;
use warnings;

use File::Copy qw(copy);
use Cwd qw(getcwd);
use File::Basename qw(dirname);

use Data::Dumper;

use ServerControl::Commons::FS;
use ServerControl::Commons::Object;
use ServerControl::Exception::SyntaxError;
use ServerControl::Exception::Unknown;

use vars qw($SKIP);
use base qw(ServerControl::Commons::Object);


$SKIP = {
   start    => 0,
   stop     => 0,
   restart  => 0,
   status   => 0,
   reload   => 0,
   create   => 0,
   recreate => 0,
};

##################################################################
# skip functions
##################################################################

sub skip_start {
   $SKIP->{"start"} = 1;
}

sub skip_stop {
   $SKIP->{"stop"} = 1;
}

sub skip_status {
   $SKIP->{"status"} = 1;
}

sub skip_restart {
   $SKIP->{"restart"} = 1;
}

##################################################################

sub Parameter {
   my $class  = shift;
   my $params = { @_ };

   if($class ne 'ServerControl::Module::Base') {
      $params->{'create'} = { isa => 'bool',   call => sub {
                                                               $class->_call_extensions('before_create');

                                                               $class->create_directories;
                                                               $class->create_files;

                                                               if($class->has('create')) {
                                                                  $class->create; 
                                                               }

                                                               $class->create_control_scripts;
                                                               $class->create_instance_conf;

                                                               $class->_call_extensions('after_create');
                                                           } };

      $params->{'start'} = { isa => 'bool', call => sub {

                                                            ServerControl->d_print("Starting instance\n");

                                                            my $wd = getcwd;
                                                            chdir(ServerControl::Args->get->{'path'});

                                                            $class->_call_extensions('before_start');

                                                            $class->start unless($SKIP->{"start"} == 1);

                                                            $class->_call_extensions('after_start');

                                                            chdir($wd);

                                                        } };
      $params->{'stop'} = { isa => 'bool', call => sub {
                                                            ServerControl->d_print("Stopping instance\n");

                                                            my $wd = getcwd;
                                                            chdir(ServerControl::Args->get->{'path'});

                                                            $class->_call_extensions('before_stop');

                                                            $class->stop unless($SKIP->{"stop"} == 1);

                                                            $class->_call_extensions('after_stop');

                                                            chdir($wd);
                                                        } };
      $params->{'restart'} = { isa => 'bool', call => sub {
                                                            ServerControl->d_print("Restarting instance\n");

                                                            my $wd = getcwd;
                                                            chdir(ServerControl::Args->get->{'path'});

                                                            $class->_call_extensions('before_restart');

                                                            $class->restart unless($SKIP->{"restart"} == 1);

                                                            $class->_call_extensions('after_restart');

                                                            chdir($wd);
                                                        } };

      $params->{'reload'} = { isa => 'bool', call => sub {
                                                            ServerControl->d_print("Reloading instance\n");

                                                            my $wd = getcwd;
                                                            chdir(ServerControl::Args->get->{'path'});

                                                            $class->_call_extensions('before_reload');

                                                            $class->reload unless($SKIP->{"reload"} == 1);

                                                            $class->_call_extensions('after_reload');

                                                            chdir($wd);
                                                        } };

      $params->{'status'} = { isa => 'bool', call => sub {
                                                            ServerControl->d_print("Status instance\n");

                                                            my $wd = getcwd;
                                                            chdir(ServerControl::Args->get->{'path'});

                                                            $class->_call_extensions('before_status');

                                                            if($SKIP->{"status"} == 0) {
                                                               my $ret = $class->status;
                                                               if($ret) {
                                                                  ServerControl->d_print("Running\n");
                                                                  exit 0;
                                                               } else {
                                                                  ServerControl->d_print("Stopped\n");
                                                                  exit 1;
                                                               }
                                                            }

                                                            $class->_call_extensions('after_status');

                                                            chdir($wd);
                                                        } };

      $params->{'recreate'} = { isa => 'bool',   call => sub {
                                                               $class->_call_extensions('before_recreate');

                                                               $class->create_control_scripts;
                                                               $class->create_instance_conf;

                                                               if($class->has('recreate')) {
                                                                  $class->recreate; 
                                                               }

                                                               $class->_call_extensions('after_recreate');
                                                           } };



   }

   no strict 'refs';

   my $parameter = (ref($class) || $class) . '::parameter';
   $$parameter = $params;
   $$parameter;
}

sub Register {
   my ($class) = @_;
   return if ($class eq 'ServerControl::Module');
   push(@{$ServerControl::MODULES}, $class);
}

sub Directories {
   my $class = shift;
   my $dirs  = { @_ };

   no strict 'refs';

   my $dir_v = $class . '::dirs';
   $$dir_v = $dirs;
   $$dir_v;
}

sub Files {
   my $class  = shift;
   my $files  = { @_ };

   no strict 'refs';

   my $file_v = $class . '::files';
   $$file_v = $files;
   $$file_v;
}

sub import {
   my ($class) = @_;
   $class->Register;
}

sub get_options {
   my ($class) = @_;
   no strict 'refs';

   my $parameter = (ref($class) || $class) . '::parameter';
   my %ret;
   for my $key (keys %{$$parameter}) {
      my $opt = $$parameter->{$key};
      if($opt->{'isa'} eq 'bool') {
         $ret{$key} = $opt->{'call'};
      } 
      elsif($opt->{'isa'} eq 'string') {
         $ret{"$key=s"} = $opt->{'call'};
      }
      elsif($opt->{'isa'} eq 'array') {
         $ret{"$key=s@"} = $opt->{'call'};
      }
      else {
         die("Unknown ISA");
      }
   }

   return %ret;
}

sub load_module {
   my ($class, $mod) = @_;

   my $mod_class = "ServerControl::Module::$mod";
   my $mod_class_file = "ServerControl/Module/$mod.pm";

   ServerControl->d_print("mod_class: $mod_class\n");
   ServerControl->d_print("mod_class_file: $mod_class_file\n");

   eval {
      require $mod_class_file;
      $mod_class->import;
   };

   if($@) {
      die($@);
   }

   return $mod_class;
}

sub get_path {
   my ($class) = @_;

   my $p = ServerControl::Args->get->{'path'};
   $p =~ s/(.*)\/+$/$1/;	# strip trailing slashes
   $p =~ s/\/{2,}/\//g;		# simplify slashes
   return $p;
}

sub get_name {
   my ($class) = @_;

   return ServerControl::Args->get->{'name'} || '';
}

sub get_directories {
   my ($class) = @_;

   my $args = ServerControl::Args->get;

   if(exists $args->{"fs-layout"} && -f $args->{"fs-layout"}) {
      return $class->_read_fs_layout_directories();
   }
   else {
      no strict 'refs';

      my $dirs = $class . '::dirs';
      return $$dirs;
   }
}

sub get_files {
   my ($class) = @_;

   my $args = ServerControl::Args->get;

   if(exists $args->{"fs-layout"} && -f $args->{"fs-layout"}) {
      return $class->_read_fs_layout_files();
   }
   else {
      no strict 'refs';

      my $files = $class . '::files';
      return $$files;
   }
}

sub create_directories {
   my ($class) = @_;

   ServerControl->d_print("Creating directroy structure\n");
   my $path = $class->get_path;
   
   recursive_mkdir($path);

   my $dirs = $class->get_directories;
   for my $dir (keys %{$dirs}) {
      my $c = $dirs->{$dir};
      recursive_mkdir($path . '/' . $dir, $c->{'chmod'});
      simple_chown($c->{'user'}, $c->{'group'}, $path . '/' . $dir);
   }

   if(exists $dirs->{"."}) {
      chmod( $dirs->{"."}->{"chmod"}, $path );
      simple_chown( $dirs->{"."}->{"user"}, $dirs->{"."}->{"group"}, $path );
   }
}

sub create_files {
   my ($class) = @_;

   ServerControl->d_print("Creating files\n");
   my $path = $class->get_path;

   my $files = $class->get_files;
   for my $file (keys %{$files}) {
      my $c = $files->{$file};

      if(exists $c->{"call"}) {
         my $code = $c->{"call"};
         &$code($path . "/" . $file);
      } elsif(exists $c->{"link"}) {
         symlink($c->{"link"}, $path . "/" . $file);
      } elsif(exists $c->{"copy"}) {
         copy($c->{"copy"}, $path . "/" . $file);
      }

      if(exists $c->{"chmod"}) {
         chmod( oct($c->{"chmod"}), "$path/$file" );
      }
   }
}

sub create_control_scripts {
   my ($class) = @_;

   ServerControl->d_print("Creating control scripts\n");

   my $bin  = $0;
   my $path = $class->get_path;

   my $args = ServerControl::Args->get;

   if(exists $args->{"no-control-links"}) {
      symlink($bin, "$path/control");
      return;
   }

   if($class->has('start')) {
      symlink($bin, "$path/start");
   }

   if($class->has('stop')) {
      symlink($bin, "$path/stop");
   }

   if($class->has('restart')) {
      symlink($bin, "$path/restart");
   }

   if($class->has('reload')) {
      symlink($bin, "$path/reload");
   }

   if($class->has('status')) {
      symlink($bin, "$path/status");
   }
}

sub create_instance_conf {
   my ($class) = @_;

   ServerControl->d_print("Creating instance.conf\n");

   # fuer die rueckwaertskompatibilitaet
   my @instance_conf;
   my $args = ServerControl::Args->get;
   for my $key (keys %{$args}) {
      my $val = $args->{$key};
      next if ($key eq 'create');

      if(ref($val) eq "ARRAY") {
         $val = join(",", @{$val});
         $key = "\@$key";
      }

      push (@instance_conf, "$key=$val");
   }

   put_file($class->get_path . '/.instance.conf', join("\n", @instance_conf));
}

################################################################################
# private methods
################################################################################

sub _call_extensions {
   my ($class, $hook) = @_;

   ServerControl->d_print("Looking for extension code ($hook)\n");

   my $extensions = ServerControl::Extension->get($hook);

   for my $ext ( @{$extensions} ) {
      # call extension code
      my $ext_class = $ext->{'class'};
      my $code  = $ext->{'code'};

      ServerControl->d_print("Found Extension in $ext_class\n");

      $ext_class->$code($class);
   }
}

# read the yaml file
sub _read_yaml_file {
   my ($class, $file) = @_;

   my $c = eval { local(@ARGV, $/) = ($file); <>; };
   my $struct;

   eval {
      require YAML;
      $struct = YAML::Load($c);  
   };

   if($@) {
      die(ServerControl::Exception::SyntaxError->new(message => $@));
   }

   return $struct;
}

# read the yaml file
sub _read_fs_layout_directories {
   my ($class, $file) = @_;

   my $struct = ServerControl::FsLayout->get;

   unless(exists $struct->{"Directories"}) {
      die(ServerControl::Exception::Unknown->new(message => "Syntax Error in YAML file ($file). No ,,Directories'' found."));
   }

   my $dirs = $struct->{"Directories"};

   my $return = {};

   ### read directories
   for my $section (qw/Base Configuration Runtime/) {
      for my $key ( keys %{$dirs->{$section}} ) {
         my $dirdef = $dirs->{$section}->{$key};

         $return->{$dirdef->{"name"}} = {
            chmod  => oct($class->_parse_fslayout_option($dirdef->{"chmod"})),
            user   => $class->_parse_fslayout_option($dirdef->{"user"}),
            group  => $class->_parse_fslayout_option($dirdef->{"group"}),
         };
      }
   }

   return $return;
}

sub _parse_fslayout_options_recursive {
   my ($class, $tmp) = @_;

   for my $key (keys %{$tmp}) {
      if(ref($tmp->{$key}) eq "HASH") {
         $class->_parse_fslayout_options_recursive($tmp->{$key});
      }
      else {
         $tmp->{$key} = $class->_parse_fslayout_option($tmp->{$key});
      }
   }

   return $tmp;
}

# read the yaml file
sub _read_fs_layout_files {
   my ($class, $file) = @_;

   my $struct = ServerControl::FsLayout->get;

   unless(exists $struct->{"Files"}) {
      die(ServerControl::Exception::Unknown->new(message => "Syntax Error in YAML file ($file). No ,,Files'' found."));
   }

   my $files = $struct->{"Files"};

   my $return = {};

   unless(exists $files->{"Exec"}) {
      die(ServerControl::Exception::Unknown->new(message => "Syntax Error in YAML file ($file). No Exec configuration found under Files."));
   }


   for my $section (qw/ Exec Base Configuration /) {
      unless(exists $files->{$section}) {
         next;
      }

      for my $filename (keys %{$files->{$section}}) {
         my $filedef = $files->{$section}->{$filename};

         if(exists $filedef->{"link"}) {
            $return->{$class->_parse_fslayout_option($filedef->{"name"})} = {
               link => $class->_parse_fslayout_option($filedef->{"link"}),
            };
         }
         elsif(exists $filedef->{"call"}) {
            $return->{$class->_parse_fslayout_option($filedef->{"name"})} = {
               call => $class->_parse_fslayout_option($filedef->{"call"}),
            };
         }
 
      }
   }

   return $return;
}

# parses the value of the yaml key.
# checks if <% ... %> is in it and tries to evaluate it
# otherwise, return it unmodified
sub _parse_fslayout_option {
   my ($class, $opt) = @_;

   if($opt =~ m/<%=.*?%>/) {
      $opt =~ s/(<%=(.*?)%>)/$class->_evaluate_template_param($2)/gems;
   }

   elsif($opt =~ m/<%(.*?)%>/) {
      $opt = $class->_evaluate_template_param($1);
   }

   return $opt;
}

# this method will evaluate the template parameters
# given in the the yaml fslayout files.
sub _evaluate_template_param {
   my ($class, $param) = @_;

   my $val = eval "$param";
   if($@) {
      die(ServerControl::Exception::SyntaxError->new(message => "Error evaluating template parameter. $@"));
   }
   
   return $val;
}



1;
