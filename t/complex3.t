#!/usr/bin/perl

use strict;
use warnings;
use PDL::LiteF;

use Test::More;

BEGIN
{
   plan tests => 15;
   use_ok( 'PDL::Complex3' );
}

# $a is four values, one in each quadrant
my $a = pdl( [ 2.9, 1.5],
             [-3.4, 1.3],
             [-5.6,-3.8],
             [ 5.3,-2.1] );

my $b = i2C(1) - $a;
my $ref = pdl( [-2.9,-0.5],
               [ 3.4,-0.3],
               [ 5.6, 4.8],
               [-5.3, 3.1]);
ok( all(approx($b, $ref)), 'value from i - piddle');

$b = $a - i2C(1);
ok( all(approx($b,-$ref)), 'value from piddle - i');


# Check that converting from re/im to mag/ang and back we get the same thing.
ok( all(approx($a->Cr2p()->Cp2r(), $a)), 'check re/im and mag/ang equivalence');

# again, but without threading
for my $asingle( $a->dog )
{
  ok( all(approx($asingle->Cr2p()->Cp2r(), $asingle)), 'check re/im and mag/ang equivalence, single');
}

# testing all the functions that are direct uses of the C library. These are all
# the @c2c and @c2r functions except Cacosh

# Octave source:
# a = [2.9 + 1.5i, -3.4 + 1.3i, -5.6 - 3.8i, 5.3 - 2.1i];
# conj( conj ( a )' )
# conj( exp  ( a )' )
# conj( sin  ( a )' )
# conj( cos  ( a )' )
# conj( tan  ( a )' )
# conj( asin ( a )' )
# conj( acos ( a )' )
# conj( atan ( a )' )
# conj( sinh ( a )' )
# conj( cosh ( a )' )
# conj( tanh ( a )' )
# conj( asinh( a )' )
# conj( atanh( a )' )
# conj( log  ( a )' )
# conj( sqrt ( a )' )
# conj( abs  ( a )' )
# conj( arg  ( a )' )

my @mathref = ( { name=> 'Cconj',
                  x   => Cconj ( $a ),
                  ref => pdl( [2.90000000000000,-1.50000000000000], [-3.40000000000000,-1.30000000000000], [-5.60000000000000,+3.80000000000000], [5.30000000000000,+2.10000000000000] ) },
                { name=> 'Cexp',
                  x   => Cexp  ( $a ),
                  ref => pdl( [1.28558818613644e+00,+1.81286188918327e+01], [8.92731062175935e-03,+3.21570874444099e-02], [-2.92489080279785e-03,+2.26256709456085e-03], [-1.01139258123735e+02,-1.72932610854796e+02] ) },
                { name=> 'Csin',
                  x   => Csin  ( $a ),
                  ref => pdl( [0.56281242248347,-2.06744127280958], [0.50364959441803,-1.64199307068320], [14.11624418296631,-17.32568170733401], [-3.44917692211222,-2.22961416164115] ) },
                { name=> 'Ccos',
                  x   => Ccos  ( $a ),
                  ref => pdl( [-2.28409132369684,-0.50942868134055], [-1.90547631560892,-0.43400651968877], [17.34303171466159,+14.10212226103006], [2.29750086276477,-3.34726042378624] ) },
                { name=> 'Ctan',
                  x   => Ctan  ( $a ),
                  ref => pdl( [-0.042417098527423,+0.914608683858376], [-0.064688041718797,+0.876457024868012], [0.000979862454446,-0.999796352376326], [-0.027992304589956,-1.011234307947049] ) },
                { name=> 'Casin',
                  x   => Casin ( $a ),
                  ref => pdl( [1.07352271311327,+1.86316171785227], [-1.19245757006443,+1.97104666926455], [-0.96949436892852,-2.60330565876526], [1.18818886924133,-2.42815800965001] ) },
                { name=> 'Cacos',
                  x   => Cacos ( $a ),
                  ref => pdl( [0.49727361368163,-1.86316171785227], [2.76325389685933,-1.97104666926455], [2.54029069572341,+2.60330565876526], [0.38260745755356,+2.42815800965001] ) },
                { name=> 'Catan',
                  x   => Catan ( $a ),
                  ref => pdl( [1.30043436966278,+0.13160199347104], [-1.31742038481709,+0.09226111919667], [-1.44830699523146,-0.08192185176637], [1.40849384129386,-0.06301814460774] ) },
                { name=> 'Csinh',
                  x   => Csinh ( $a ),
                  ref => pdl( [0.64084799876145,+9.09175213899291], [-4.00321717642344,+14.45215547838675], [106.94781591614847,+82.73239693503834], [-50.56836906849791,-86.46845982270531] ) },
                { name=> 'Ccosh',
                  x   => Ccosh ( $a ),
                  ref => pdl( [0.64474018737499,+9.03686675283983], [4.01214448704520,-14.41999839094234], [-106.95074080695126,-82.73013436794378], [-50.57088905523755,-86.46415103209036] ) },
                { name=> 'Ctanh',
                  x   => Ctanh ( $a ),
                  ref => pdl( [1.006012165683547,+0.000859642357838], [-1.001909925030369,+0.001150499837326], [-0.999993128120553,-0.000026470864841], [1.000024430042004,+0.000043433441936] ) },
                { name=> 'Casinh',
                  x   => Casinh( $a ),
                  ref => pdl( [1.89018322198598,+0.45897015324710], [-1.99913017822970,+0.35312616220093], [-2.60733777986101,-0.59115768137063], [2.43936553816831,-0.37206784516781] ) },
                { name=> 'Catanh',
                  x   => Catanh( $a ),
                  ref => pdl( [0.27294073670563,+1.42023853428871], [-0.25967163193423,+1.46622567679102], [-0.12202434317211,-1.48677481412582], [0.16383071797315,-1.50452056064656] ) },
                { name=> 'Clog',
                  x   => Clog  ( $a ),
                  ref => pdl( [1.18324920936885,+0.47734538237367], [1.29199877621612,+2.77639120380162], [1.91214204556007,-2.54539351229231], [1.74062004466785,-0.37724905964236] ) },
                { name=> 'Csqrt',
                  x   => Csqrt ( $a ),
                  ref => pdl( [1.755700080233367,+0.427180022626820], [0.346449812123098,+1.876173625313001], [0.764058154290448,-2.486721710030643], [2.345301379939867,-0.447703655053033] ) },
                { name=> 'Cabs',
                  x   => Cabs  ( $a ),
                  ref => pdl(3.26496554346290,3.64005494464026,6.76756972627545,5.70087712549569) },
                { name=> 'Carg',
                  x   => Carg  ( $a ),
                  ref => pdl(0.477345382373672,2.776391203801620,-2.545393512292313,-0.377249059642359) } );

for my $vals ( @mathref )
{
  ok( all(approx( $vals->{x}, $vals->{ref})), "$vals->{name}" );
}

# acosh() is has a periodic ambiguity, and octave and libc have a different
# convention. I thus make sure that cosh(acosh()) matches
ok( all(approx( $a, Ccosh( Cacosh( $a ) ))), "Cacosh" );

# now the pairwise functions. Octave code:
# conj(a(1:2) .* a(3:4))'
# conj(a(1:2) ./ a(3:4))'
# conj(a(1:2) .** a(3:4))'
ok( all(approx( Cmul($a->slice(':,0:1'), $a->slice(':,2:3')), pdl([-10.5400000000000, -19.4200000000000], [-15.2900000000000,  14.0300000000000]))),
                "Cmul" );
ok( all(approx( Cdiv($a->slice(':,0:1'), $a->slice(':,2:3')), pdl([-0.479039301310044, + 0.057205240174673], [-0.638461538461539, - 0.007692307692308]))),
                "Cdiv" );
ok( all(approx( Cpow($a->slice(':,0:1'), $a->slice(':,2:3')), pdl([5.14002978831410e-03, -6.29803626245641e-03], [2.70845250817957e+05, -1.71582867513522e+05]))),
                "Cpow" );

# Now the various functions we defined ourselves
ok( all(approx($a->Cabs ** 2.0, $a->Cabs2)), 'Cabs2');
ok( all(approx(sequence(3)->r2C, pdl([0,0],[1,0],[2,0]))), 'r2C');
ok( all(approx(sequence(3)->i2C, pdl([0,0],[0,1],[0,2]))), 'i2C');

my $z = pdl(0,0);
$z = $z->Cpow(2);
ok($z->at(0) == 0 && $z->at(1) == 0, 'check that 0 +0i exponentiates correctly'); # Wasn't always so.

# Check stringification of complex piddle
# This is sf.net bug #1176614
my $c =  pdl(9.1234, 4.1234);
my $c211 = $c->dummy(2,1);
my $c211str = $c211->Cstring;
ok($c211str=~/(9.123|4.123)/, 'sf.net bug #1176614');

ok( all(approx( $a->Csumover,  $a->mv(1,0)->sumover)),  "Csumover" );

#octave code: a(1) * a(2) * a(3) * a(4)
my $prod = pdl(433.6192, 149.0556);
ok( all(approx( $a->Cprodover, $prod)),                 "Cprodover" );

# octave a * 23
ok( all(approx( Cscale($a, 23), pdl([  66.7,  34.5],
                                    [ -78.2,  29.9],
                                    [-128.8, -87.4],
                                    [ 121.9, -48.3] ))), "Cscale" );

# octave code:
# roots( [1,0,0,-a(1)] )
# roots( [1,0,0,-a(2)] )
# roots( [1,0,0,-a(3)] )
# roots( [1,0,0,-a(4)] )
# manually reordered the roots to make things match
my $roots_ref = pdl( [[1.464778172092365, + 0.235055403205951],[-0.935953036519331, + 1.151007406337947],[-0.528825135573034, - 1.386062809543898]],
                     [[0.925221566885388, + 1.228933194991425],[-1.526898149859244, + 0.186798783556277],[0.601676582973855, - 1.415731978547703]],
                     [[1.250551811285992, - 1.419143287776877],[0.603738233181950, + 1.792581281210752],[-1.854290044467944, - 0.373437993433873]],
                     [[1.772301995281784, - 0.224048626307236],[-0.692119195575819, + 1.646882864245491],[-1.080182799705965, - 1.422834237938255]] );
ok( all(approx( Croots($a, 3), $roots_ref )), "Croots" );

# octave: 3* a.**2 + 2*a + 1
my $poly_ref = pdl( [25.28, +  29.10],
                    [23.81, -  23.92],
                    [40.56, + 120.08],
                    [82.64, -  70.98] );
ok( all(approx( rCpolynomial( pdl(1,2,3), $a ), $poly_ref)), "rCpolynomial" );


# should add some more tests to test the inplace operation and the various types
