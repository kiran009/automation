#!/usr/bin/perl
# Tertio 7.6 Build Script
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
my $database="/data/ccmdb/provident/";
my $dbbmloc="/data/ccmbm/provident/";
my $hostname = hostname;
my $hostplatform;
if($hostname =~ /pesthp2/)
{
	$ENV{'PATH'}="/usr/contrib/bin:$ENV{'PATH'}";
}
my $result=GetOptions("coreproject=s"=>\$coreproject,"javaproject=s"=>\$javaprojectname,"buildnumber=s"=>\$build_number);
if(!$result)
{
	print "Please provide coreprojectname \n";
	exit;
}
if(!$coreproject)
{
	print "You need to supply core project name \n";
	exit;
}
push(@projectlist,$coreproject);
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
#my $mailto='kiran.daadhi@evolving.com hari.annamalai@evolving.com Srikanth.Bhaskar@evolving.com anand.gubbi@evolving.com shreraam.gurumoorthy@evolving.com';
#my $mailto='kiran.daadhi@evolving.com';
my %hash;
$destdir="/u/kkdaadhi/Tertio_Deliverable";
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
my $tertiodest="/u/kkdaadhi/Tertio_Dest";
#my $tertiodest="/data/releases/tertio/7.6.0/patches";
# /* Global Environment Variables ******* /
sub main()
{
		pkg();
}
sub pkg()
{
	umask 002;
	open LOCATION,">>$Bin/location.txt";
	foreach $prj(@projectlist)
	{
  	if($prj =~ /linAS5/)
  	{
			$destdir="/u/kkdaadhi/Tertio_Deliverable/linAS5";
  		chdir($destdir);
  		copy("$Bin/tertio_7.6_README.txt",$destdir);
  			$hostos="rhel5";
  			$hostplatform="linAS5";
  			`find * -type f -name "*README.txt" | xargs tar cvf tertio-$mrnumber-$hostos-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$mrnumber-$hostos-build$build_number\.tar;gzip tertio-$mrnumber-$hostos-build$build_number\.tar;`;
  			print "tertio-$mrnumber-$hostos-build$build_number\.tar\.gz => $tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz";
  			copy("tertio-$mrnumber-$hostos-build$build_number\.tar\.gz","$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
  			push(@location,"$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz");
  			print LOCATION "$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz \n";
		}
		elsif($prj =~ /sol10/)
		{
			$destdir="/u/kkdaadhi/Tertio_Deliverable/sol10";
  		chdir($destdir);
  		copy("$Bin/tertio_7.6_README.txt",$destdir);
  			$hostplatform="sol10";
  			`find * -type f -name "*README.txt" | xargs tar cvf tertio-$mrnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$mrnumber-$hostplatform-build$build_number\.tar; gzip tertio-$mrnumber-$hostplatform-build$build_number\.tar;`;
  			print "tertio-$mrnumber-$hostplatform-build$build_number\.tar\.gz => $tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz";
  			copy("tertio-$mrnumber-$hostplatform-build$build_number\.tar\.gz","$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
  			push(@location,"$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz");
  			print LOCATION "$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz  \n";
		}
		elsif($prj =~ /hpiav3/)
		{
			$destdir="/u/kkdaadhi/Tertio_Deliverable/hpiav3";
  		chdir($destdir);
  		copy("$Bin/tertio_7.6_README.txt",$destdir);
  			$hostplatform="hpiav3";
  			`find * -type f -name "*README.txt" | xargs tar cvf tertio-$mrnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$mrnumber-$hostplatform-build$build_number\.tar; /usr/contrib/bin/gzip tertio-$mrnumber-$hostplatform-build$build_number\.tar;`;
  			print "tertio-$mrnumber-$hostplatform-build$build_number\.tar\.gz => $tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz";
  			copy("tertio-$mrnumber-$hostplatform-build$build_number\.tar\.gz","$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
  			push(@location,"$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz");
  			print LOCATION "$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz  \n";
		}
		elsif($prj =~ /RHEL6/)
		{
			$destdir="/u/kkdaadhi/Tertio_Deliverable/rhel6";
  		chdir($destdir);
  		copy("$Bin/tertio_7.6_README.txt",$destdir);
  		$hostplatform="rhel6";
  		`find * -type f -name "*README.txt" | xargs tar cvf tertio-$mrnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$mrnumber-$hostplatform-build$build_number\.tar; /usr/contrib/bin/gzip tertio-$mrnumber-$hostplatform-build$build_number\.tar;`;
  		print "tertio-$mrnumber-$hostplatform-build$build_number\.tar\.gz => $tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz";
  		copy("tertio-$mrnumber-$hostplatform-build$build_number\.tar\.gz","$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
  		push(@location,"$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz");
  		print LOCATION "$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz  \n";
		}
  	`tar -cvf $Bin/logs.tar $Bin/reconfigure_devproject_*.log`;
  	close LOCATION;
  	}
}
main();
