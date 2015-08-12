#!/usr/bin/perl
# dsa 7.6 Build Script
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
my $hostname = hostname;
my $hostplatform;
my $result=GetOptions("delproject=s"=>\$delprojectname,"database=s"=>\$db);
if(!$result)
{
	print "Please provide coreprojectname \n";
	exit;
}
if(!$delproject)
{
	print "You need to supply delivery project name \n";
	exit;
}
$delprojectname=~ s/^\s+|\s+$//g;
$db=~ s/^\s+|\s+$//g;
my $database="/data/ccmdb/$db/";
my $dbbmloc="/data/ccmbm/$db/";
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
$destdir="/u/kkdaadhi/DSAMS_Deliverable";
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
my $dsadest="/u/kkdaadhi/DSAMS_Dest";
#my $dsadest="/data/releases/dsa/7.6.0/patches";
my $tertiodest="/u/kkdaadhi/DSAMS";
#my $tertiodest="/data/releases/tertio/7.6.0/patches";
# /* Global Environment Variables ******* /
my %deliveryhash;
sub main()
{
		pkg();
}
sub pkg()
{
	umask 002;
	open LOCATION,">>$Bin/location.txt";
	open OP,"< $Bin/patchbinarylist.txt";
	my @op=<OP>;
	close OP;
	foreach $op(@op)
	{
		next if ($op=~ m/AFFECTS:/);
  	$delroot="$dbbmloc/$delprojectname/DSA_MS_Delivery/";
		$location=$op =~ tr/\$MSHOME\///cd;
		$deliveryhash{$delroot/$location}=$location;
	}
	#DSA_MS_Delivery
	#rmtree($destdir);
	foreach $key(keys %deliveryhash)
  		{
				print "Key: $key Value: $deliveryhash{$key}";
	  		$dirname=dirname($deliveryhash{$key});
  			mkpath("$destdir/$dirname");
  			copy("$key","$destdir/$deliveryhash{$key}") or die("Couldn't able to copy the file $!");
  		}
  		#chdir($destdir);
			# Read hash

  #		copy("$Bin/dsa_4.0_README.txt",$destdir);

  #		if($prj =~ /linAS5/)
  #		{
  #			$hostos="rhel5";
  #			$hostplatform="linAS5";
  #			`chmod -R 0775 *; find * -type f -name "*README.txt" | xargs tar cvf dsa-$mrnumber-$hostos-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf dsa-$mrnumber-$hostos-build$build_number\.tar;gzip dsa-$mrnumber-$hostos-build$build_number\.tar;`;
  #			print "dsa-$mrnumber-$hostos-build$build_number\.tar\.gz => $dsadest/$hostplatform/NotTested/dsa-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz";
  #			copy("dsa-$mrnumber-$hostos-build$build_number\.tar\.gz","$dsadest/$hostplatform/NotTested/dsa-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
  #			push(@location,"$dsadest/$hostplatform/NotTested/dsa-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz");
  #			print LOCATION "$dsadest/$hostplatform/NotTested/dsa-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz \n";
#
#  		}
#  		elsif($prj =~ /hpiav3/)
#  		{
#  			$hostplatform="hpiav3";
#  			`chmod -R 0775 *;  find * -type f -name "*README.txt" | xargs tar cvf dsa-$mrnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf dsa-$mrnumber-$hostplatform-build$build_number\.tar; /usr/contrib/bin/gzip dsa-$mrnumber-$hostplatform-build$build_number\.tar;`;
#  			print "dsa-$mrnumber-$hostplatform-build$build_number\.tar\.gz => $dsadest/$hostplatform/NotTested/dsa-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz";
#  			copy("dsa-$mrnumber-$hostplatform-build$build_number\.tar\.gz","$dsadest/$hostplatform/NotTested/dsa-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
#  			push(@location,"$dsadest/$hostplatform/NotTested/dsa-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz");
#  			print LOCATION "$dsadest/$hostplatform/NotTested/dsa-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz  \n";
#  		}
#  		elsif($prj =~ /sol10/)
#  		{
#  			$hostplatform="sol10";
#  			`chmod -R 0775 *; find * -type f -name "*README.txt" | xargs tar cvf dsa-$mrnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf dsa-$mrnumber-$hostplatform-build$build_number\.tar; gzip dsa-$mrnumber-$hostplatform-build$build_number\.tar;`;
#  			print "dsa-$mrnumber-$hostplatform-build$build_number\.tar\.gz => $dsadest/$hostplatform/NotTested/dsa-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz";
#  			copy("dsa-$mrnumber-$hostplatform-build$build_number\.tar\.gz","$dsadest/$hostplatform/NotTested/dsa-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
#  			push(@location,"$dsadest/$hostplatform/NotTested/dsa-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz");
#  			print LOCATION "$dsadest/$hostplatform/NotTested/dsa-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz  \n";
#  		}
#  		`tar -cvf $Bin/logs.tar $Bin/reconfigure_devproject_*.log`;
#  		close LOCATION;
}
main();
