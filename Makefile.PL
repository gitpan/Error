use ExtUtils::MakeMaker;
WriteMakefile(
	NAME	=> 'Error',
	VERSION_FROM	=> 'Error.pm',
	'dist'	=> {
			COMPRESS => 'gzip -9f',
			SUFFIX   => '.gz', 
			DIST_DEFAULT => 'all tardist',
		   },

);
