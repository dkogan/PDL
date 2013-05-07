
# Makefile.PL for PDL::Primitive module.

# Use this as a template for the Makefile.PL for
# any external PDL module.

use ExtUtils::MakeMaker;

PDL::Core::Dev->import();

@pack = (["complex3.pd",Complex3,PDL::Complex3]);

%hash = pdlpp_stdargs_int(@::pack);
$hash{LIBS} = ['-lm'];
$hash{CCFLAGS} = "$Config{ccflags} --std=c99";

$hash{depend} = { 'Complex3.pm' => join(' ', qw(complex3.include.c
                                                complex3.include.pm
                                                complex3.pod) )};

WriteMakefile(%hash);

sub MY::postamble {
	pdlpp_postamble_int(@::pack);
}  # Add genpp rule
