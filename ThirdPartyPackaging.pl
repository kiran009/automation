#!/usr/bin/perl
# Tertio 3rdparty Packaging Script
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
my $result=GetOptions("platform=s"=>\$platform,"ftpdir=s"=>\$ftpdir);
if(!$result)
{
	print "Please provide devprojectname \n";
	exit;
}
if(!$platform)
{
	print "You need to supply the platform where packaging happens \n";
	exit;
}
if(!$ftpdir)
{
	print "You need to supply tertio destination directory \n";
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
my @platforms;
my $workarea;
my @op;
my @file_list;
my $patch_number;
my @patchbinarylist;
my $cr;
my %hash;
my $readmeIssue;
my @consumreadme;

my $hostname = hostname;
my %machinehash=('pedhp2'=>hpia, 'pedlinux5'=>linAS5, 'pesthp2'=>hpiav3, 'pedlinux1'=>linAS3, 'pedsun3'=>sol9, 'pedsun2'=>sol10);
# /* Global Environment Variables ******* /
sub main()
{
	  # $platform=$machinehash{$hostname};
		# print $platform;
		# copyBinaries();
		createTar();
}

sub createTar()
{
	umask 002;
	open OP,"<$Bin/patchnumber.txt";
	$patchnumber=<OP>;
	close OP;
	open LOCATION,">>$Bin/location.txt";
	$platform=~ s/^\s+|\s+$//g;
	$patchnumber=~ s/^\s+|\s+$//g;
	open BN,"<$Bin/build_number.txt";
	$build_number=<BN>;
	close BN;
  if($platform =~ /linAS5/)
  {
		$destdir="/u/kkdaadhi/Tertio_Deliverable/linAS5";
  	chdir($destdir);
  	#copy("$Bin/$patchnumber\_README.txt",$destdir);
  	$hostos="rhel5";
  	$hostplatform="linAS5";
  	`find * -type f  \\( ! -name "*README.txt" ! -name "*:.tar" \\) | xargs tar uvf tertio-$patchnumber-$hostos-build$build_number\.tar;`;
  	#`find * -type f -name "*README.txt" | xargs tar cvf tertio-$patchnumber-$hostos-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$patchnumber-$hostos-build$build_number\.tar;`;
  	print "tertio-$patchnumber-$hostos-build$build_number\.tar => $ftpdir/$hostplatform/NotTested/tertio-$patchnumber-$hostos-build$build_number\_$dtformat\.tar";
  	copy("tertio-$patchnumber-$hostos-build$build_number\.tar","$ftpdir/$hostplatform/NotTested/tertio-$patchnumber-$hostos-build$build_number\_$dtformat\.tar") or die("Couldn't copy to destination $!");
  	push(@location,"$ftpdir/$hostplatform/NotTested/tertio-$patchnumber-$hostos-build$build_number\_$dtformat\.tar");
  	print LOCATION "$ftpdir/$hostplatform/NotTested/tertio-$patchnumber-$hostos-build$build_number\_$dtformat\.tar \n";
	}
	elsif($platform =~ /hpiav3/)
	{
		$destdir="/u/kkdaadhi/Tertio_Deliverable/hpiav3";
  	chdir($destdir);
  	#copy("$Bin/$patchnumber\_README.txt",$destdir);
  	$hostplatform="hpiav3";
  	`find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$patchnumber-$hostplatform-build$build_number\.tar;`;
  	#`find * -type f -name "*README.txt" | xargs tar cvf tertio-$patchnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$patchnumber-$hostplatform-build$build_number\.tar; gzip tertio-$patchnumber-$hostplatform-build$build_number\.tar;`;
  	print "tertio-$patchnumber-$hostplatform-build$build_number\.tar => $ftpdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar";
  	copy("tertio-$patchnumber-$hostplatform-build$build_number\.tar","$ftpdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar") or die("Couldn't copy to destination $!");
  	push(@location,"$ftpdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar");
  	print LOCATION "$ftpdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar  \n";
	}
  elsif($platform =~ /linAS3/)
  {
		$destdir="/u/kkdaadhi/Tertio_Deliverable/linAS3";
  	chdir($destdir);
  	#copy("$Bin/$patchnumber\_README.txt",$destdir);
  	$hostos="rhel3";
  	$hostplatform="linAS3";
  	`find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$patchnumber-$hostos-build$build_number\.tar;`;
  	#`find * -type f -name "*README.txt" | xargs tar cvf tertio-patch$patchnumber\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-patch$patchnumber\.tar;`;
  	print "tertio-patch$patchnumber\.tar => $ftpdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar";
  	copy("tertio-patch$patchnumber\.tar","$ftpdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar") or die("Couldn't copy to destination $!");
  	push(@location,"$ftpdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar");
  	print LOCATION "$ftpdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar \n";
	}
  elsif($platform =~ /sol9/)
  {
		$destdir="/u/kkdaadhi/Tertio_Deliverable/sol9";
  	chdir($destdir);
  	#copy("$Bin/$patchnumber\_README.txt",$destdir);
  	$hostplatform="sol9";
  	`find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-patch$patchnumber\.tar;`;
  	#`find * -type f -name "*README.txt" | xargs tar cvf tertio-patch$patchnumber\.tar;find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-patch$patchnumber\.tar;`;
  	print "tertio-patch$patchnumber\.tar => $ftpdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar";
  	copy("tertio-patch$patchnumber\.tar","$ftpdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar") or die("Couldn't copy to destination $!");
  	push(@location,"$ftpdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar");
  	print LOCATION "$ftpdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar \n";
	}
  elsif($platform =~ /hpia/)
  {
		$destdir="/u/kkdaadhi/Tertio_Deliverable/hpia";
  	chdir($destdir);
  	#copy("$Bin/$patchnumber\_README.txt",$destdir);
  	$hostplatform="hpia";
  	`find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-patch$patchnumber\.tar;`;
  	#`find * -type f -name "*README.txt" | xargs tar cvf tertio-patch$patchnumber\.tar;find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-patch$patchnumber\.tar;`;
  	print "tertio-patch$patchnumber\.tar => $ftpdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar";
  	copy("tertio-patch$patchnumber\.tar","$ftpdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar") or die("Couldn't copy to destination $!");
  	push(@location,"$ftpdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar");
  	print LOCATION "$ftpdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar \n";
	}
	elsif($platform =~ /sol10/)
	{
		$destdir="/u/kkdaadhi/Tertio_Deliverable/sol10";
  	chdir($destdir);
  	#copy("$Bin/$patchnumber\_README.txt",$destdir);
  	$hostplatform="sol10";
  	`find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$patchnumber-$hostplatform-build$build_number\.tar;`;
  	#`find * -type f -name "*README.txt" | xargs tar cvf tertio-$patchnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$patchnumber-$hostplatform-build$build_number\.tar;`;
  	print "tertio-$patchnumber-$hostplatform-build$build_number\.tar => $ftpdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar";
  	copy("tertio-$patchnumber-$hostplatform-build$build_number\.tar","$ftpdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar") or die("Couldn't copy to destination $!");
		#dummy comment.
  	push(@location,"$ftpdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar");
  	print LOCATION "$ftpdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar \n";
	}
	elsif($platform =~ /RHEL6/)
	{
		$destdir="/u/kkdaadhi/Tertio_Deliverable/rhel6";
  	chdir($destdir);
  	#copy("$Bin/$patchnumber\_README.txt",$destdir);
  	$hostplatform="rhel6";
  	`find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$patchnumber-$hostplatform-build$build_number\.tar;`;
  	#`find * -type f -name "*README.txt" | xargs tar cvf tertio-$patchnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$patchnumber-$hostplatform-build$build_number\.tar;`;
  	print "tertio-$patchnumber-$hostplatform-build$build_number\.tar => $ftpdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar";
  	copy("tertio-$patchnumber-$hostplatform-build$build_number\.tar","$ftpdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar") or die("Couldn't copy to destination $!");
  	push(@location,"$ftpdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar");
  	print LOCATION "$ftpdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar \n";
	}
  close LOCATION;
}
main();
