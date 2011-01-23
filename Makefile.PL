use ExtUtils::MakeMaker;

WriteMakefile(
   NAME => 'ServerControl',
   VERSION_FROM => 'lib/ServerControl.pm',
   PREREQ_PM => {},
   EXE_FILES => ['bin/servercontrol'],
   LICENSE => 'perl, bsd'
);

