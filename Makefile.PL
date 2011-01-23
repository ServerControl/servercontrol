use ExtUtils::MakeMaker;

WriteMakefile(
   NAME => 'ServerControl',
   VERSION_FROM => 'lib/ServerControl.pm',
   EXE_FILES => ['bin/servercontrol'],
   LICENSE => 'bsd'
);

