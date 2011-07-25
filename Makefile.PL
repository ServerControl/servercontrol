use ExtUtils::MakeMaker;

WriteMakefile(
# use perl Makefile.PL INSTALL_BASE=/path instead..
#   INSTALL_BASE => '/usr/', 
   NAME => 'ServerControl',
   VERSION_FROM => 'lib/ServerControl.pm',
   EXE_FILES => ['bin/servercontrol','bin/sc_create_initfile'],
   PREREQ_PM => {'YAML' => 0, 'Devel::StackTrace' => 0},
   LICENSE => 'bsd'
);

