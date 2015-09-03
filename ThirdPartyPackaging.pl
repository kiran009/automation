#!/usr/bin/perl
# Tertio Packaging Script
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
# $ENV{'CCM_HOME'}="/opt/ccm71";
# $ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
# $CCM="$ENV{'CCM_HOME'}/bin/ccm";
# my $database="/data/ccmdb/provident/";
# my $dbbmloc="/data/ccmbm/provident/";
# $result=GetOptions("crs=s"=>\$crs);
my $result=GetOptions("platform=s"=>\$platform,"destdir=s"=>\$destdir);
if(!$result)
{
	print "Please provide devprojectname \n";
	exit;
}
# if(!$crs)
if(!$platform)
{
	print "You need to supply the platform where packaging happens \n";
	exit;
}
if(!$destdir)
{
	print "You need to supply tertio destination directory \n";
	exit;
}
# {
# 	print "No extra CRs are provided for this build, proceeding with already added one's \n";
# }
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
#$destdir="/u/kkdaadhi/Tertio_Deliverable";
my $readmeIssue;
my @consumreadme;

# @crs=split(/,/,$crs);
# print "The following list of CRs to the included in the patch:@crs\n";
my $hostname = hostname;
my %machinehash=('pedhp2'=>hpia, 'pedlinux5'=>linAS5, 'pesthp2'=>hpiav3, 'pedlinux1'=>linAS3, 'pedsun3'=>sol9, 'pedsun2'=>sol10);
my $platform;
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
  	copy("$Bin/$patchnumber\_README.txt",$destdir);
  	$hostos="rhel5";
  	$hostplatform="linAS5";
  	`find * -type f -name "*README.txt" | xargs tar cvf tertio-$patchnumber-$hostos-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$patchnumber-$hostos-build$build_number\.tar;`;
  	print "tertio-$patchnumber-$hostos-build$build_number\.tar\.gz => $destdir/$hostplatform/NotTested/tertio-$patchnumber-$hostos-build$build_number\_$dtformat\.tar\.gz";
  	copy("tertio-$patchnumber-$hostos-build$build_number\.tar\.gz","$destdir/$hostplatform/NotTested/tertio-$patchnumber-$hostos-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
  	push(@location,"$destdir/$hostplatform/NotTested/tertio-$patchnumber-$hostos-build$build_number\_$dtformat\.tar\.gz");
  	print LOCATION "$destdir/$hostplatform/NotTested/tertio-$patchnumber-$hostos-build$build_number\_$dtformat\.tar\.gz \n";
	}
	elsif($platform =~ /hpiav3/)
	{
		$destdir="/u/kkdaadhi/Tertio_Deliverable/hpiav3";
  	chdir($destdir);
  	copy("$Bin/$patchnumber\_README.txt",$destdir);
  	$hostplatform="hpiav3";
  	`find * -type f -name "*README.txt" | xargs tar cvf tertio-$patchnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$patchnumber-$hostplatform-build$build_number\.tar; gzip tertio-$patchnumber-$hostplatform-build$build_number\.tar;`;
  	print "tertio-$patchnumber-$hostplatform-build$build_number\.tar\.gz => $destdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz";
  	copy("tertio-$patchnumber-$hostplatform-build$build_number\.tar\.gz","$destdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
  	push(@location,"$destdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz");
  	print LOCATION "$destdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz  \n";
	}
  elsif($platform =~ /linAS3/)
  {
		$destdir="/u/kkdaadhi/Tertio_Deliverable/linAS3";
  	chdir($destdir);
  	copy("$Bin/$patchnumber\_README.txt",$destdir);
  	$hostos="rhel3";
  	$hostplatform="linAS3";
  	#`find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$patchnumber-$hostos-build$build_number\.tar;gzip tertio-$patchnumber-$hostos-build$build_number\.tar;`;
  	`find * -type f -name "*README.txt" | xargs tar cvf tertio-patch$patchnumber\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-patch$patchnumber\.tar;`;
  	print "tertio-patch$patchnumber\.tar => $destdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar";
  	copy("tertio-patch$patchnumber\.tar","$destdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar") or die("Couldn't copy to destination $!");
  	push(@location,"$destdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar");
  	print LOCATION "$destdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar \n";
	}
  elsif($platform =~ /sol9/)
  {
		$destdir="/u/kkdaadhi/Tertio_Deliverable/sol9";
  	chdir($destdir);
  	copy("$Bin/$patchnumber\_README.txt",$destdir);
  	$hostplatform="sol9";
  	`find * -type f -name "*README.txt" | xargs tar cvf tertio-patch$patchnumber\.tar;find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-patch$patchnumber\.tar;`;
  	print "tertio-patch$patchnumber\.tar => $destdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar";
  	copy("tertio-patch$patchnumber\.tar","$destdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar") or die("Couldn't copy to destination $!");
  	push(@location,"$destdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar");
  	print LOCATION "$destdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar \n";
	}
  elsif($platform =~ /hpia/)
  {
		$destdir="/u/kkdaadhi/Tertio_Deliverable/hpia";
  	chdir($destdir);
  	copy("$Bin/$patchnumber\_README.txt",$destdir);
  	$hostplatform="hpia";
  	`find * -type f -name "*README.txt" | xargs tar cvf tertio-patch$patchnumber\.tar;find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-patch$patchnumber\.tar;`;
  	print "tertio-patch$patchnumber\.tar => $destdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar";
  	copy("tertio-patch$patchnumber\.tar","$destdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar") or die("Couldn't copy to destination $!");
  	push(@location,"$destdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar");
  	print LOCATION "$destdir/$hostplatform/NotTested/tertio-patch$patchnumber\.tar \n";
	}
	elsif($platform =~ /sol10/)
	{
		$destdir="/u/kkdaadhi/Tertio_Deliverable/sol10";
  	chdir($destdir);
  	copy("$Bin/$patchnumber\_README.txt",$destdir);
  	$hostplatform="sol10";
  	`find * -type f -name "*README.txt" | xargs tar cvf tertio-$patchnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$patchnumber-$hostplatform-build$build_number\.tar;`;
  	print "tertio-$patchnumber-$hostplatform-build$build_number\.tar\.gz => $destdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz";
  	copy("tertio-$patchnumber-$hostplatform-build$build_number\.tar\.gz","$destdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
		#dummy comment.
  	push(@location,"$destdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz");
  	print LOCATION "$destdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz  \n";
	}
	elsif($platform =~ /RHEL6/)
	{
		$destdir="/u/kkdaadhi/Tertio_Deliverable/rhel6";
  	chdir($destdir);
  	copy("$Bin/$patchnumber\_README.txt",$destdir);
  	$hostplatform="rhel6";
  	`find * -type f -name "*README.txt" | xargs tar cvf tertio-$patchnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$patchnumber-$hostplatform-build$build_number\.tar;`;
  	print "tertio-$patchnumber-$hostplatform-build$build_number\.tar\.gz => $destdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz";
  	copy("tertio-$patchnumber-$hostplatform-build$build_number\.tar\.gz","$destdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
  	push(@location,"$destdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz");
  	print LOCATION "$destdir/$hostplatform/NotTested/tertio-$patchnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz  \n";
	}
  close LOCATION;
}
# sub copyBinaries()
# {
# 	umask 002;
# 	# Choose the platform project
# 	$platform=~ s/^\s+|\s+$//g;
# 	$binarylist="$Bin/fileplacement.fp";
#   if($platform =~ /linAS5/)
#   {
# 		$destdir="/u/kkdaadhi/Tertio_Deliverable/linAS5";
# 	}
#   elsif($platform =~ /linAS3/)
#   {
# 		$destdir="/u/kkdaadhi/Tertio_Deliverable/linAS3";
# 	}
# 	elsif($platform =~ /sol10/)
# 	{
# 		$destdir="/u/kkdaadhi/Tertio_Deliverable/sol10";
# 	}
# 	elsif($platform =~ /sol9/)
# 	{
# 		$destdir="/u/kkdaadhi/Tertio_Deliverable/sol9";
# 	}
# 	elsif($platform =~ /hpiav3/)
# 	{
# 		$destdir="/u/kkdaadhi/Tertio_Deliverable/hpiav3";
# 	}
# 	elsif($platform =~ /hpia/)
# 	{
# 		$destdir="/u/kkdaadhi/Tertio_Deliverable/hpia";
# 	}
# 	elsif($platform =~ /RHEL6/)
# 	{
# 		$destdir="/u/kkdaadhi/Tertio_Deliverable/rhel6";
# 	}
# 	rmtree($destdir);
# 	open OP, "< $binarylist";
#   @file_list=<OP>;
#   close OP;
#   my %deliveryhash;
# 	# Select the basedirectory of the project and construct the delivery hash
#   $delroot="$dbbmloc/$platform/Provident_Dev/";
#   foreach $file(@file_list)
#   {
#   	if($file =~ /TOMESRC/)
#   	{
#   		my @del=split(/\s+/,$file);
#   		if($del[3] eq ".")
#   		{
#   			$deliveryhash{$del[1]}="$del[1],$del[5]";
#   		}
#   		else
#   		{
#   			$deliveryhash{$del[1]}="$del[3],$del[5]";
#   		}
#   	}
#   	elsif($file =~ /DASHBOARDSRC/)
#   	{
#   		my @del=split(/\s+/,$file);
#   		if($del[3] eq ".")
#   		{
#   			$deliveryhash{$del[1]}="$del[1],$del[5]";
#   		}
#   		else
#   		{
#   			$deliveryhash{$del[1]}="$del[3],$del[5]";
#   		}
#   	}
#   	else
#   	{
# 			print "Invalid file for this kind of packaging \n";
#   		# my @del=split(/\s+/,$file);
#   		# if($del[3] eq ".")
#   		# {
# 			# 	$deliveryhash{"$delroot/$del[1]"}="$del[1],$del[5]";
#   		# }
#   		# else
#   		# {
#   		# 	$deliveryhash{"$delroot/$del[1]"}="$del[3],$del[5]";
#   		# }
#   	}
#   	}
#   #  open OP, "< $javabinarylist";
#   #  @file_list=<OP>;
#   #  close OP;
#   #  $delroot="$dbbmloc/$javaprojectname/Provident_Java/";
#   #  foreach $file(@file_list)
#   #  {
#   #  	my @del=split(/\s+/,$file);
#   #  	if($del[3] eq ".")
#   #  	{
#  # 			$deliveryhash{"$delroot/$del[1]"}="$del[1],$del[5]";
#  # 		}
#   # else
#   #  	{
# 	#  		$deliveryhash{"$delroot/$del[1]"}="$del[3],$del[5]";
#   #  	}
#   #  }
# 	# Read the hash and copy the binaries
# 	foreach $key(keys %deliveryhash)
#   {
# 		$dirname=dirname($deliveryhash{$key});
# 		($filename,$permission)=split(/,/,$deliveryhash{$key});
# 		$filename=~ s/^\s+|\s+$//g;
# 		$permission=~ s/^\s+|\s+$//g;
#   	mkpath("$destdir/$dirname");
# 		#copy("$key","$destdir/$filename") or die("Couldn't able to copy the file $!");
# 		copy("$key","$destdir/$filename") or die("Couldn't able to copy the file $key $!");
# 		chmod(oct($permission),"$destdir/$filename") or die("Couldn't able to set the permission $!");
# 		print "Permission: $permission for file: $destdir/$filename \n";
#   }
#   }


main();
