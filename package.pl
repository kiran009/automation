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
	print "Please provide Delivery Projectname and Database \n";
	exit;
}
if(!$delprojectname)
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
		#$op =~ tr/\$MSHOME\///cd;
		$op =~ s/\$MSHOME\///g;
		$op=~ s/^\s+|\s+$//g;
		print "OP is: $op\n";
		$deliveryhash{"$delroot/$op"}=$op;
	}
	#DSA_MS_Delivery
	rmtree($destdir);
	foreach $key(keys %deliveryhash)
  {
		print "Key: $key Value: $deliveryhash{$key}";
	  $dirname=dirname($deliveryhash{$key});
  	mkpath("$destdir/$dirname");
  	copy("$key","$destdir/$deliveryhash{$key}") or die("Couldn't able to copy the file $!");
  }
	open OP,"< patchnumber.txt";
	my $patch_number=<OP>;
	close OP;
  copy("$Bin/$patch_number\_README.txt",$destdir);
	chdir($destdir);
  if($delprojectname =~ /linAS5/)
  {
  	$hostos="rhel5";
  	$hostplatform="linAS5";
		`chmod -R 0775 *; find * -type f -name "$patch_number\_README.txt" | xargs tar cvf ms-patch$patch_number\.tar; find * -type f  \\( ! -name "$patch_number\_README.txt" ! -name "*.tar" \\) | xargs tar uvf ms-patch$patch_number\.tar;`;
		copy("ms-patch$patch_number\.tar","$dsadest/$hostplatform/NotTested/") or die("Couldn't copy to destination $!");
		print LOCATION "$dsadest/$hostplatform/NotTested/ms-patch$patch_number\.tar \n";
	}
	elsif($delprojectname =~ /sol10/)
	{
		$hostplatform="sol10";
		`chmod -R 0775 *; find * -type f -name "$patch_number\_README.txt" | xargs tar cvf ms-patch$patch_number\.tar; find * -type f  \\( ! -name "$patch_number\_README.txt" ! -name "*.tar" \\) | xargs tar uvf ms-patch$patch_number\.tar;`;
		copy("ms-patch$patch_number\.tar","$dsadest/$hostplatform/NotTested/") or die("Couldn't copy to destination $!");
		print LOCATION "$dsadest/$hostplatform/NotTested/ms-patch$patch_number\.tar \n";
	}
  elsif($delprojectname =~ /RHEL6/)
  {
  	$hostos="rhel6";
  	$hostplatform="rhel6";
		`chmod -R 0775 *; find * -type f -name "$patch_number\_README.txt" | xargs tar cvf ms-patch$patch_number\.tar; find * -type f  \\( ! -name "$patch_number\_README.txt" ! -name "*.tar" \\) | xargs tar uvf ms-patch$patch_number\.tar;`;
		copy("ms-patch$patch_number\.tar","$dsadest/$hostplatform/NotTested/") or die("Couldn't copy to destination $!");
		print LOCATION "$dsadest/$hostplatform/NotTested/ms-patch$patch_number\.tar \n";
	}
  		close LOCATION;
}
main();
