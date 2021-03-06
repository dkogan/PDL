
# Makefile.PL for PDL::Primitive module.

# Use this as a template for the Makefile.PL for
# any external PDL module.

use ExtUtils::MakeMaker;
use Config;

PDL::Core::Dev->import();

@pack = (["primitive.pd",Primitive,PDL::Primitive]);

if ($^O eq 'dec_osf') {
       require Config;
       if ($Config::Config{cc} =~ /^cc/) {
               my $no_optimize = $::PDL_OPTIONS{OPTIMIZE}
                                || $Config::Config{optimize}
                                || '-g2';
               $no_optimize =~ s/(\s|^)(-O)\d/$1${2}0/;
               $no_optimize =~ s/(\s|^)(-g)\d/$1${2}2/;
               print <<EOT;
       Digital Unix cc optimizer has a bug that is
       triggered by primitive.c. Therefore
EOT
               # Becaue OPTIMIZE in PASTHRU it can't be overridden so
               # it gets hard coded in Makefile
               eval q|
                       sub MY::const_cccmd {
                               package MY;
                               my $defval = shift->SUPER::const_cccmd(@_);
                               $defval =~ s/\$\(OPTIMIZE\)/|
                                       . $no_optimize . q|/gs;
                               print "$defval\n";
                               return $defval;
                       };
               |;
       }
}


#WriteMakefile(
# pdlpp_stdargs_int(@::pack)
#);
%hash = pdlpp_stdargs_int(@::pack);
$hash{LIBS}->[0] .= ' -lm';

# If we don't do this, and Perl core is using the wrapped API, then it will
# call (say) srand48_r(), and get its random numbers from drand48_r(), but we
# will get ours from drand48(), and srand48() never gets called.
$hash{CCFLAGS} ||= $Config{ccflags};
$hash{CCFLAGS} .= ' -DPERL_REENTR_API';

WriteMakefile(%hash);

sub MY::postamble {
	pdlpp_postamble_int(@::pack);
}  # Add genpp rule
