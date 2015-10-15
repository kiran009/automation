#!/usr/bin/perl
# DSA createTarfile script
use Cwd;
use File::Path;
use File::Find;
use File::Basename;
use Switch;
use Getopt::Long;
use File::Copy;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Sys::Hostname;

#/************ Setting Environment Variables *******************/
# my $binarylist="$Bin/fileplacement.fp";
# my $javabinarylist="$Bin/javabinaries.fp";
my $hostname = hostname;
my $hostplatform;
if($hostname =~ /pesthp2/)
{
	$ENV{'PATH'}="/usr/contrib/bin:$ENV{'PATH'}";
}
my $result=GetOptions("coreproject=s"=>\$coreproject,"pseudoroot=s"=>\$pseudoroot,"mrprefix=s"=>\$mrprefix,"readmename=s"=>\$readmename,"destination=s"=>\$destination);
if(!$result)
{
	print "You must supply arguments to the script\n";
	exit;
}
if(!$coreproject)
{
	print "You need to supply core project name \n";
	exit;
}
if(!$pseudoroot)
{
    print "You need to supply Pseudoroot \n";
    exit;
}
if(!$destination)
{
	print "Destination directory is mandatory\n";
	exit;
}
if(!$mrprefix)
{
    print "MR Prefix is mandatory \n";
    exit;
}
if(!$readmename)
{
    print "Readmename is mandatory \n";
    exit;
}
my @PatchFiles;
my @files;
my $patch_number;
my $problem_number;
my @crs;
my @tasks;
my $tasklist;
my $CRlist;
my $PatchReleaseVersion;
my $projectName;
my $platformlist;
my @op;
my @file_list;
my $mrnumber;
my @location_explode;
my %hash;
my $destdir;
my $readmeIssue;
@months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year+=1900;
my $dt="$mday $months[$mon] $year\n";
my @taskinfo;
my @synopsis;
my @summary;
my @crresolv;
my @formattsks;
my @binarylist;
my $dtformat="$year$months[$mon]$mday$hour$min";
my 	@location;
# /* Global Environment Variables ******* /
sub main()
{
		createTar();
}
sub createTar()
{
	umask 002;
	open OP,"<$Bin/mrnumber.txt";
	$mrnumber=<OP>;
	close OP;
	open LOCATION,">>$Bin/location.txt";
	$coreproject=~ s/^\s+|\s+$//g;
	$pseudoroot=~ s/^\s+|\s+$//g;
	$mrnumber=~ s/^\s+|\s+$//g;
	$readmename=~ s/^\s+|\s+$//g;
	$mrprefix=~ s/^\s+|\s+$//g;
	open BN,"<$Bin/build_number.txt";
	$build_number=<BN>;
	close BN;
  if($coreproject =~ /linAS5/)
  {
	$destdir="$pseudoroot/linAS5";
  	chdir($destdir);
  	copy("$Bin/$readmename",$destdir);
  	$hostos="rhel5";
  	$hostplatform="linAS5";
  	`find * -type f -name "*README.txt" | xargs tar cvf $mrprefix-$mrnumber-$hostos-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf $mrprefix-$mrnumber-$hostos-build$build_number\.tar;gzip $mrprefix-$mrnumber-$hostos-build$build_number\.tar;`;
  	print "$mrprefix-$mrnumber-$hostos-build$build_number\.tar\.gz => $destination/$hostplatform/NotTested/$mrprefix-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz";
  	copy("$mrprefix-$mrnumber-$hostos-build$build_number\.tar\.gz","$destination/$hostplatform/NotTested/$mrprefix-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
  	push(@location,"$destination/$hostplatform/NotTested/$mrprefix-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz");
  	print LOCATION "$destination/$hostplatform/NotTested/$mrprefix-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz \n";
	}
	elsif($coreproject =~ /RHEL6/)
    {
        $destdir="$pseudoroot/rhel6";
        chdir($destdir);
        copy("$Bin/$readmename",$destdir);
        $hostos="rhel6";
        `find * -type f -name "*README.txt" | xargs tar cvf $mrprefix-$mrnumber-$hostos-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf $mrprefix-$mrnumber-$hostos-build$build_number\.tar;gzip $mrprefix-$mrnumber-$hostos-build$build_number\.tar;`;
        print "$mrprefix-$mrnumber-$hostos-build$build_number\.tar\.gz => $destination/$hostos/NotTested/$mrprefix-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz";
        copy("$mrprefix-$mrnumber-$hostos-build$build_number\.tar\.gz","$destination/$hostos/NotTested/$mrprefix-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
        push(@location,"$destination/$hostos/NotTested/$mrprefix-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz");
        print LOCATION "$destination/$hostos/NotTested/$mrprefix-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz \n";
        }

	elsif($coreproject =~ /sol10/)
	{
		$destdir="$pseudoroot/sol10";
  	    chdir($destdir);
  	    copy("$Bin/$readmename",$destdir);
  	    $hostplatform="sol10";
  	    `find * -type f -name "*README.txt" | xargs tar cvf $mrprefix-$mrnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf $mrprefix-$mrnumber-$hostplatform-build$build_number\.tar;gzip $mrprefix-$mrnumber-$hostplatform-build$build_number\.tar;`;
  	    print "$mrprefix-$mrnumber-$hostplatform-build$build_number\.tar\.gz => $destination/$hostplatform/NotTested/$mrprefix-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz";
  	    copy("$mrprefix-$mrnumber-$hostplatform-build$build_number\.tar\.gz","$destination/$hostplatform/NotTested/$mrprefix-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
  	    push(@location,"$destination/$hostplatform/NotTested/$mrprefix-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz");
  	    print LOCATION "$destination/$hostplatform/NotTested/$mrprefix-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz \n";
	}
	elsif($coreproject =~ /hpiav3/)
	{
		$destdir="$pseudoroot/hpiav3";
  	    chdir($destdir);
  	    copy("$Bin/$readmename",$destdir);
  	    $hostplatform="hpiav3";
  	    `find * -type f -name "*README.txt" | xargs tar cvf $mrprefix-$mrnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf $mrprefix-$mrnumber-$hostplatform-build$build_number\.tar; gzip $mrprefix-$mrnumber-$hostplatform-build$build_number\.tar;`;
  	    print "$mrprefix-$mrnumber-$hostplatform-build$build_number\.tar\.gz => $destination/$hostplatform/NotTested/$mrprefix-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz";
  	    copy("$mrprefix-$mrnumber-$hostplatform-build$build_number\.tar\.gz","$destination/$hostplatform/NotTested/$mrprefix-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
  	    push(@location,"$destination/$hostplatform/NotTested/$mrprefix-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz");
  	    print LOCATION "$destination/$hostplatform/NotTested/$mrprefix-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz  \n";
	}
  close LOCATION;
}
main();
