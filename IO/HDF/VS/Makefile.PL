#
# Makefile.PL for PDL::IO::HDF::VS module.
#

use PDL::Core::Dev;
use ExtUtils::MakeMaker;
use Config;

$package = [ "VS.pd" , VS , PDL::IO::HDF::VS ];
WriteMakefile(
    NAME => 'PDL::IO::HDF::VS',
    TYPEMAPS => [ &PDL_TYPEMAP() ],
    OBJECT => 'VS.o',
    PM => {
        'VS.pm' => '$(INST_LIBDIR)/VS.pm',
    },
    INC => &PDL_INCLUDE() . " -I$hdf_include_path",
    LIBS => [ "-L$hdf_lib_path -lmfhdf -ldf -ljpeg -lz $szip" ],
    clean => {
        FILES => 'VS.pm VS.xs VS.o VS.c',
    },
    dist => { 
        COMPRESS => 'gzip', 
        SUFFIX => 'gz', 
    }, 
);

sub MY::postamble { pdlpp_postamble($package); }        