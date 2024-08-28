#!/usr/bin/perl

# purpose: predict the initial value for q, deltaD, deltaO18 and dexcess inside the bag. This corresponds to the true value, or corrected value, in the case of the profiles
# the program numerically solves the differential equations for q(t) and R(t), but time is reversed compared to evolution_bag.pl
# the results for q0, deltaO180 and d0 are written as the last 3 numbers in the last line of the output file.

sub commande {
        $char=$_[0];
        print "$char\n";
        system($char);
}
sub delta {
	$R=$_[0];
	$delta=($R-1)*1e3;
	return $delta;
}
sub R {
	$delta=$_[0];
	$R=$delta/1e3+1;
	return $R;
}

# final conditions in the bag
$qf=3.8462; # g/kg
$deltaO18f=-57.7554; # permil
$dexcessf=19.1101; # permil
$delay=0.5; # dealy of measurement, in hours

# chose the environmental conditions
$qe=12.0298; # g/kg
$deltaO18e=-22.1931; # permil
$dexcesse=8.3064; # permil

# chose bag properties
$lambdad=0.0255; #
$alphaO18=0.0255/0.0249; # hour-1 # estimate as the -slope of ln((R(t)-Re)/(R0-Re)) as a function of time in hours in the expertiment where q0=qe
$alphaHDO=0.0255/0.0244;  # hour-1  # estimate as the -slope of ln((R(t)-Re)/(R0-Re)) as a function of time in hours in the expertiment where q0=qe
 

# **** no more choices below this line

# personal comments to check if it works:
# example: in outputs/evolution_bag_q06_deltaO0-5_d020_qe14_deltaOe-12_de10.txt, at 5 hours: 
# q,deltaO18,dexcess= 7.53210195909745 -54.7570477343098 344.319556616177
# tail -1 outputs/correction_bag_qf7.5_deltaOf-54.8_df344.3_qe14_deltaOe-12_de10.txt
# if dt=0.02 -> 5.96174583828756 -4.39052608098511 15.4671886848147
# if dt=0.01 -> almost the same
# if more precise final conditions: tail -1 outputs/correction_bag_qf7.53_deltaOf-54.76_df344.3_qe14_deltaOe-12_de10.txt
# -> 5.99884547288009 -4.95359584630095 19.621355545711 -> OK
# if less precise for df: tail -1 outputs/correction_bag_qf7.53_deltaOf-54.76_df344_qe14_deltaOe-12_de10.txt
# -> 5.99884547288009 -4.95359584630095 19.1851442350957 -> OK
# if less precise for deltaO18f: tail -1 outputs/correction_bag_qf7.53_deltaOf-54.8_df344_qe14_deltaOe-12_de10.txt
# -> 5.99884547288009 -5.01239968064648 19.1902828452034
# conclusion: the precision for qf, deltaO18f and df should be 1e-2 g/kg, 0.1 permil, 1 permil. The precision for qf is most important!

$dt=0.02; # time step of integration, in hours
$nt=int($delay/$dt); # number of time steps

# final and environment conditions
$ROf=R($deltaO18f);
$deltaDf=$dexcessf+8*$deltaO18f;
$RDf=R($deltaDf);
$ROe=R($deltaO18e);
$deltaDe=$dexcesse+8*$deltaO18e;
$RDe=R($deltaDe);
print "deltaDf,deltaDe=$deltaDf,$deltaDe\n";

# initialisation
$q=$qf;
$RD=$RDf;
$RO=$ROf;
$deltaO=delta($RO);
$deltaD=delta($RD);
$dexcess=$deltaD-8*$deltaO;
print "dexcess=$dexcess\n";
if (abs($dexcessf-$dexcess)>1e-3) {print "pgm 61, exit\n"; exit(1);}

# print these values in a file
$tag="qf$qf"."_deltaOf$deltaO18f"."_df$dexcessf"."_qe$qe"."_deltaOe$deltaO18e"."_de$dexcesse";
$fileout="outputs/correction_bag_1_$tag.txt";
print "fileout=$fileout\n";
if (-d "figs/")  {} else {commande("mkdir figs");}
if (-d "outputs/")  {} else {commande("mkdir outputs");}
commande("echo \"t(hour) qf(g/kg) deltaO18f(permil) dexcessf(permil) qe(g/kg) deltaO18e(permil) dexcesse(permil) q(g/kg) deltaO18(permil) dexcess(permil)\" > $fileout");
commande("echo \"$delay $qf $deltaO18f $dexcessf $qe $deltaO18e $dexcesse $q $deltaO $dexcess\" >> $fileout");

# time loop
for ($it=1;$it<=$nt;$it++) {
$t=$delay-$it*$dt;
print "\n * it,t=$it,$t\n";

#for q(t), we use this differential equation: dq/dt=lambdad*(qe-q)
$dqdt=$lambdad*($qe-$q);
$q=$q-$dqdt*$dt;
print "q=$q\n";

# for R(t), we use this differential equation: dR/dt=lambdad/q*((Re*qe-R*q)/alpha-R*(qe-q))
$dROdt=$lambdad/$q*(($ROe*$qe-$RO*$q)/$alphaO18-$RO*($qe-$q));
$RO=$RO-$dROdt*$dt;
$dRDdt=$lambdad/$q*(($RDe*$qe-$RD*$q)/$alphaHDO-$RD*($qe-$q));
$RD=$RD-$dRDdt*$dt;

$deltaO=delta($RO);
$deltaD=delta($RD);
$dexcess=$deltaD-8*$deltaO;
print "deltaO18,deltaD,dexcess=$deltaO,$deltaD,$dexcess\n";


# print these values in a file
commande("echo \"$t $qf $deltaO18f $dexcessf $qe $deltaO18e $dexcesse $q $deltaO $dexcess\" >> $fileout");

} # for it

print "pgm 106: ends up without errors\n";
