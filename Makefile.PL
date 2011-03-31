use ExtUtils::MakeMaker;

WriteMakefile(
   INSTALL_BASE => '/usr/',
   NAME => 'ServerControl',
   VERSION_FROM => 'lib/ServerControl.pm',
   EXE_FILES => ['bin/servercontrol','bin/sc_init','bin/sc_updaterc'],
   LICENSE => 'bsd'
);

