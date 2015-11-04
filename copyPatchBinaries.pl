#!/usr/bin/perl
# Tertio 7.X copying binaries script
use Cwd;
use File::Path;
use File::Find;
use File::Basename;
#use Switch;
use Getopt::Long;
use File::Copy;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Sys::Hostname;
#/************ Setting Environment Variables *******************/
my $database="/data/ccmdb/provident/";
my $dbbmloc="/data/ccmbm/provident/";
my $binarylist;
#="$Bin/fileplacement.fp";
my $javabinarylist;
#="$Bin/javabinaries.fp";
my $hostplatform;
my $result=GetOptions("coreproject=s"=>\$coreproject,"javaproject=s"=>\$javaprojectname,"buildnumber=s"=>\$build_number,"crlist=s"=>\$crlist);
if(!$result)
{
	print "You must supply arguments to the script\n";
	exit;
}
if(!$coreproject)
{
	print "You need to supply core projectname \n";
	exit;
}
if(!$javaprojectname)
{
	print "You need to supply java projectname \n";
	exit;
}
if(!$crlist)
{
	print "CR list is mandatory \n";
	exit;
}
my @PatchFiles;
my @files;
my $patch_number;
my $destdir;
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
my @location_explode;
my %hash;
my $readmeIssue;
my $database="/data/ccmdb/provident/";
my $dbbmloc="/data/ccmbm/provident/";
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
my @location;
my $tertiodest="/u/kkdaadhi/Tertio_Dest";
my $deliverable_list;
my $patch_number;
@crs=split(/,/,$crlist);
#/************ Setting Environment Variables *******************/
$ENV{'CCM_HOME'}="/opt/ccm71";
$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
$CCM="$ENV{'CCM_HOME'}/bin/ccm";
#my $tertiodest="/data/releases/tertio/7.6.0/patches";
# /* Global Environment Variables ******* /
sub main()
{
		#start_ccm();
		#constructfp();
		copyBinaries();
		#ccm_stop();
}
sub constructfp()
{
	open COREFP, "+> $Bin/fileplacement.fp";
	open JAVAFP, "+> $Bin/javabinaries.fp";
	foreach $cr(@crs)
	{
		$cr=~ s/^\s+|\s+$//g;
		print "$CCM query \"cvtype='problem' and problem_number='$cr'\" -u -f \"%deliverable_list\"";
		@deliverable_list=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%deliverable_list"`;
		foreach $deliverable_list(@deliverable_list)
		{
			$deliverable_list=~ s/^\s+|\s+$//g;
			if($deliverable_list =~ /jar/)

			{
					print JAVAFP "$deliverable_list\n";
			}
			else
			{
					print COREFP "$deliverable_list\n";
			}

		}
		`$CCM query "cvtype=\'problem\' and problem_number=\'$cr\'"`;
    $patch_number=`$CCM query -u -f %patch_number`;
    $patch_readme=`$CCM query -u -f %patch_readme`;
    $patch_number=~ s/^\s+|\s+$//g;

		open OP, "+> $Bin/patchnumber.txt";
		print OP $patch_number;
		close OP;
}
}
sub copyBinaries()
{
	umask 002;
	# Choose the platform project
	$coreproject=~ s/^\s+|\s+$//g;
	#copy("$dbbmloc/$coreproject/Provident_Dev/mr_package/fileplacement.fp","$Bin/fileplacement.fp") or die("Couldn't able to copy the file, can't proceed with binary copy $!");
	#copy("$dbbmloc/$coreproject/Provident_Dev/mr_package/javabinaries.fp","$Bin/javabinaries.fp") or die("Couldn't able to copy the file, can't proceed with binary copy $!");
	$binarylist="$Bin/fileplacement.fp";
	$javabinarylist="$Bin/javabinaries.fp";
  if($coreproject =~ /linAS5/)
  {
		$destdir="/u/kkdaadhi/Tertio_Deliverable/linAS5";
	}
  elsif($coreproject =~ /linAS3/)
  {
		$destdir="/u/kkdaadhi/Tertio_Deliverable/linAS3";
	}
  elsif($coreproject =~ /linAS4/)
  {
		$destdir="/u/kkdaadhi/Tertio_Deliverable/linAS4";
	}
	elsif($coreproject =~ /sol10/)
	{
		$destdir="/u/kkdaadhi/Tertio_Deliverable/sol10";
	}
	elsif($coreproject =~ /sol9/)
	{
		$destdir="/u/kkdaadhi/Tertio_Deliverable/sol9";
	}
	elsif($coreproject =~ /hpiav3/)
	{
		$destdir="/u/kkdaadhi/Tertio_Deliverable/hpiav3";
	}
	elsif($coreproject =~ /hpia/)
	{
		$destdir="/u/kkdaadhi/Tertio_Deliverable/hpia";
	}
	elsif($coreproject =~ /RHEL6/)
	{
		$destdir="/u/kkdaadhi/Tertio_Deliverable/rhel6";
	}
	#rmtree($destdir);
	# Remove Destnation directory keeping the root
	`rm -rf $destdir/*`;
	open OP, "< $binarylist";
  @file_list=<OP>;
  close OP;
  my %deliveryhash;
	# Select the basedirectory of the project and construct the delivery hash
  $delroot="$dbbmloc/$coreproject/Provident_Dev/";
  foreach $file(@file_list)
  {
  	if($file =~ /TOMESRC/)
  	{
  		my @del=split(/\s+/,$file);
  		if($del[3] eq ".")
  		{
  			$deliveryhash{$del[1]}="$del[1],$del[5]";
  		}
  		else
  		{
  			$deliveryhash{$del[1]}="$del[3],$del[5]";
  		}
  	}
  	elsif($file =~ /DASHBOARDSRC/)
  	{
  		my @del=split(/\s+/,$file);
  		if($del[3] eq ".")
  		{
  			$deliveryhash{$del[1]}="$del[1],$del[5]";
  		}
  		else
  		{
  			$deliveryhash{$del[1]}="$del[3],$del[5]";
  		}
  	}
  	else
  	{
  		my @del=split(/\s+/,$file);
  		if($del[3] eq ".")
  		{
				$deliveryhash{"$delroot/$del[1]"}="$del[1],$del[5]";
  		}
  		else
  		{
  			$deliveryhash{"$delroot/$del[1]"}="$del[3],$del[5]";
  		}
  	}
  	}
   open OP, "< $javabinarylist";
   @file_list=<OP>;
   close OP;
   $delroot="$dbbmloc/$javaprojectname/Provident_Java/";
   foreach $file(@file_list)
   {
   	my @del=split(/\s+/,$file);
   	if($del[3] eq ".")
   	{
 			$deliveryhash{"$delroot/$del[1]"}="$del[1],$del[5]";
 		}
  else
   	{
	 		$deliveryhash{"$delroot/$del[1]"}="$del[3],$del[5]";
   	}
   }
	# Read the hash and copy the binaries
	foreach $key(keys %deliveryhash)
  {
		$dirname=dirname($deliveryhash{$key});
		($filename,$permission)=split(/,/,$deliveryhash{$key});
		$filename=~ s/^\s+|\s+$//g;
		$permission=~ s/^\s+|\s+$//g;
  	    mkpath("$destdir/$dirname");
		#copy("$key","$destdir/$filename") or die("Couldn't able to copy the file $!");
		# Remove the file prior to copying
  	    unlink "$destdir/$filename" if -e "$destdir/$filename";
		copy("$key","$destdir/$filename") or die("Couldn't able to copy the file $key $!");
		chmod(oct($permission),"$destdir/$filename") or die("Couldn't able to set the permission $!");
		print "Permission: $permission for file: $destdir/$filename \n";
  }
  }
sub start_ccm()
{
	print "In Start CCM \n";
	open(ccm_addr,"$ENV{'CCM_HOME'}/bin/ccm start -d $database -m -q -r build_mgr -h ccmuk1 -nogui |");
	$ENV{'CCM_ADDR'}=<ccm_addr>;
	close(ccm_addr);
}

sub ccm_stop()
{
	print "In Stop CCM \n";
	open(ccm_addr,"$ENV{'CCM_HOME'}/bin/ccm stop |");
	close(ccm_addr);
}
main();
