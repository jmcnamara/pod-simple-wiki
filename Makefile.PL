use ExtUtils::MakeMaker;


WriteMakefile(
    ($] >= 5.005 ? (
    'AUTHOR'        => 'John McNamara (jmcnamara@cpan.org)',
    'ABSTRACT'      => 'A class for creating Pod to Wiki filters.', ) : () ),
    'NAME'          => 'Pod::Simple::Wiki',
    'VERSION_FROM'  => 'lib/Pod/Simple/Wiki.pm',
    'NEEDS_LINKING' =>  0,
    'PREREQ_PM'     => {Pod::Simple => 0},
    'dist'          => {COMPRESS => 'gzip --best', SUFFIX => 'gz'},
    'EXE_FILES'     => ['bin/pod2wiki'],
    'LICENSE'       => 'perl',
);
