use strict;
use warnings;

use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "inc");

use Test::Run::Builder;

my $build = Test::Run::Builder->new(
    'module_name' => "Error",
    configure_requires => { 'Module::Build' => '0.39', },
    'requires'    =>
    {
        'Scalar::Util' => 0,
        'perl' => "5.6.0",
        'strict' => 0,
        'warnings' => 0,
    },
    'license'  => "perl",
    'dist_abstract' => 'Error/exception handling in an OO-ish way',
    'dist_author'   => 'Shlomi Fish ( http://www.shlomifish.org/ )',
);
$build->create_build_script;
