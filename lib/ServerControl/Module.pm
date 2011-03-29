#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Module;

use strict;
use warnings;

use Switch;
use File::Copy qw(copy);
use Cwd qw(getcwd);
use File::Basename qw(dirname);

use Data::Dumper;

use ServerControl::Commons::FS;
use ServerControl::Commons::Object;

use base qw(ServerControl::Commons::Object);

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

                                                            $class->start;

                                                            $class->_call_extensions('after_start');

                                                            chdir($wd);

                                                        } };
      $params->{'stop'} = { isa => 'bool', call => sub {
                                                            ServerControl->d_print("Stopping instance\n");

                                                            my $wd = getcwd;
                                                            chdir(ServerControl::Args->get->{'path'});

                                                            $class->_call_extensions('before_stop');

                                                            $class->stop;

                                                            $class->_call_extensions('after_stop');

                                                            chdir($wd);
                                                        } };
      $params->{'restart'} = { isa => 'bool', call => sub {
                                                            ServerControl->d_print("Restarting instance\n");

                                                            my $wd = getcwd;
                                                            chdir(ServerControl::Args->get->{'path'});

                                                            $class->_call_extensions('before_restart');

                                                            $class->restart;

                                                            $class->_call_extensions('after_restart');

                                                            chdir($wd);
                                                        } };

      $params->{'reload'} = { isa => 'bool', call => sub {
                                                            ServerControl->d_print("Reloading instance\n");

                                                            my $wd = getcwd;
                                                            chdir(ServerControl::Args->get->{'path'});

                                                            $class->_call_extensions('before_reload');

                                                            $class->reload;

                                                            $class->_call_extensions('after_reload');

                                                            chdir($wd);
                                                        } };

      $params->{'status'} = { isa => 'bool', call => sub {
                                                            ServerControl->d_print("Status instance\n");

                                                            my $wd = getcwd;
                                                            chdir(ServerControl::Args->get->{'path'});

                                                            $class->_call_extensions('before_status');

                                                            my $ret = $class->status;
                                                            if($ret) {
                                                               ServerControl->d_print("Running\n");
                                                               exit 0;
                                                            } else {
                                                               ServerControl->d_print("Stopped\n");
                                                               exit 1;
                                                            }

                                                            $class->_call_extensions('after_status');

                                                            chdir($wd);
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
      switch ($opt->{'isa'}) {
         case 'bool'   { $ret{$key} = $opt->{'call'}; }
         case 'string' { $ret{"$key=s"} = $opt->{'call'}; }
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

   no strict 'refs';

   my $dirs = $class . '::dirs';
   $$dirs;
}

sub get_files {
   my ($class) = @_;

   no strict 'refs';

   my $files = $class . '::files';
   $$files;
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

      # wenn scalar, dann nur symlinken
      unless(ref($c)) {
         symlink($c, $path . '/' . $file);
         next;
      }

      if(exists $c->{'call'}) {
         my $code = $c->{'call'};
         &$code($path . '/' . $file);
      } elsif(exists $c->{'link'}) {
         symlink($c->{'link'}, $path . '/' . $file);
      } elsif(exists $c->{'copy'}) {
         copy($c->{'copy'}, $path . '/' . $file);
      }
   }
}

sub create_control_scripts {
   my ($class) = @_;

   ServerControl->d_print("Creating control scripts\n");

   my $bin  = $0;
   my $path = $class->get_path;

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

      push (@instance_conf, "$key=$val");
   }
   put_file($class->get_path . '/conf/instance.conf', join("\n", @instance_conf));
}

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

1;
