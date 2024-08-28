#!/usr/bin/perl

# purpose: predict the evolution of q, deltaD, deltaO18 and dexcess inside the bag
# the program numerically solves the differential equations for q(t) and R(t).

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

# chose the initial conditions in the bag
$q0=6.0; # g/kg
$deltaO180=-5.0; # permil
$dexcess0=20.0; # permil

# chose the environmental conditions
$qe=14.0; # g/kg
$deltaO18e=-12.0; # permil
$dexcesse=10.0; # permil

# chose bag properties
$lambda=0.0425; # hour-1 # estimate as the -slope of ln((q(t)-qe)/(q0-qe)) as a function of time in hours in the experiment where q0<qe
$alphaO18=0.0425/0.0316; # hour-1 # estimate as the -slope of ln((R(t)-Re)/(R0-Re)) as a function of time in hours in the expertiment where q0=qe
$alphaHDO=0.0425/0.0294; # hour-1  # estimate as the -slope of ln((R(t)-Re)/(R0-Re)) as a function of time in hours in the expertiment where q0=qe

# **** no more choices below this line

$deltat=40.0; # duration of experiment, in hours
$dt=0.02; # time step of integration, in hours
$nt=int($deltat/$dt); # number of time steps

# initial and environment conditions
$RO0=R($deltaO180);
$deltaD0=$dexcess0+8*$deltaO180;
$RD0=R($deltaD0);
$ROe=R($deltaO18e);
$deltaDe=$dexcesse+8*$deltaO18e;
$RDe=R($deltaDe);
print "deltaD0,deltaDe=$deltaD0,$deltaDe\n";

# initialisation
$q=$q0;
$RD=$RD0;
$RO=$RO0;
$deltaO=delta($RO);
$deltaD=delta($RD);
$dexcess=$deltaD-8*$deltaO;
print "dexcess=$dexcess\n";
if (abs($dexcess0-$dexcess)>1e-3) {print "pgm 61, exit\n"; exit(1);}

# print these values in a file
$tag="q0$q0"."_deltaO0$deltaO180"."_d0$dexcess0"."_qe$qe"."_deltaOe$deltaO18e"."_de$dexcesse";
$fileout="outputs/evolution_bag_$tag.txt";
print "fileout=$fileout\n";
if (-d "figs/")  {} else {commande("mkdir figs");}
if (-d "outputs/")  {} else {commande("mkdir outputs");}
commande("echo \"t(hour) q0(g/kg) deltaO180(permil) dexcess0(permil) qe(g/kg) deltaO18e(permil) dexcesse(permil) q(g/kg) deltaO18(permil) dexcess(permil)\" > $fileout");
commande("echo \"0 $q0 $deltaO180 $dexcess0 $qe $deltaO18e $dexcesse $q $deltaO $dexcess\" >> $fileout");

# time loop
for ($it=1;$it<=$nt;$it++) {
$t=$it*$dt;
print "\n * it,t=$it,$t\n";

#for q(t), we use this differential equation: dq/dt=lambda*(qe-q)
$dqdt=$lambda*($qe-$q);
$q=$q+$dqdt*$dt;
print "q=$q\n";

# check that it corresponds to the analytical solution: q(t)=qe+(q0-qe)*exp(-lambda*t)
$qanalytic=$qe+($q0-$qe)*exp(-$lambda*$t);
print "qanalytic=$qanalytic\n";
if (abs($q-$qanalytic)>1e-2) {print "pgm 62, exit\n"; exit(1);}

# for R(t), we use this differential equation: dR/dt=lambda/q*((Re*qe-R*q)/alpha-R*(qe-q))
$dROdt=$lambda/$q*(($ROe*$qe-$RO*$q)/$alphaO18-$RO*($qe-$q));
$RO=$RO+$dROdt*$dt;
$dRDdt=$lambda/$q*(($RDe*$qe-$RD*$q)/$alphaHDO-$RD*($qe-$q));
$RD=$RD+$dRDdt*$dt;

$deltaO=delta($RO);
$deltaD=delta($RD);
$dexcess=$deltaD-8*$deltaO;
print "deltaO18,deltaD,dexcess=$deltaO,$deltaD,$dexcess\n";

# check that it corresponds to the analytical solution if qe=q0: R(t)=Re+(R0-Re)*exp(-lambda/alpha*t)
if (abs($qe-$q0)<1e-3) {
print "check R(t)\n";
$ROanalytic=$ROe+($RO0-$ROe)*exp(-$lambda/$alphaO18*$t);
$RDanalytic=$RDe+($RD0-$RDe)*exp(-$lambda/$alphaHDO*$t);
$deltaOanalytic=delta($ROanalytic);
$deltaDanalytic=delta($RDanalytic);
$dexcessanalytic=$deltaDanalytic-8*$deltaOanalytic;
print "deltaO18analytic,deltaDanalytic,dexcessanalytic=$deltaOanalytic,$deltaDanalytic,$dexcessanalytic\n";
if (abs($deltaO-$deltaOanalytic)>1e-2) {print "pgm 91, exit\n"; exit(1);}
if (abs($deltaD-$deltaDanalytic)>1e-2) {print "pgm 92, exit\n"; exit(1);}
if (abs($dexcess-$dexcessanalytic)>1e-2) {print "pgm 93, exit\n"; exit(1);}
}

# print these values in a file
commande("echo \"$t $q0 $deltaO180 $dexcess0 $qe $deltaO18e $dexcesse $q $deltaO $dexcess\" >> $fileout");

} # for it

# makes some plot: if this does not work on your laptop, you can remove this part and make your own plots.
print "pgm 111: now makes some plots\n";
commande("sed 's/tag/$tag/' < gnuplot_evolution_bag.plot > gnuplot_evolution_bag.plot.tmp");
commande("gnuplot gnuplot_evolution_bag.plot.tmp");
commande("gv figs/evolution_bag_deltaO18_$tag.eps&");
commande("gv figs/evolution_bag_dexcess_$tag.eps&");

print "pgm 106: ends up without errors\n";

