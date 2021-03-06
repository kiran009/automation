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
my $javabinarylist;
my $hostplatform;
my $result=GetOptions("coreproject=s"=>\$coreproject,"javaproject=s"=>\$javaprojectname,"buildnumber=s"=>\$build_number);
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
sub main()
{
		copyBinaries();
}
sub copyBinaries()
{
	umask 002;
	$coreproject=~ s/^\s+|\s+$//g;
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
main();