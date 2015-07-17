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
my $binarylist="$Bin/fileplacement.fp";
my $javabinarylist="$Bin/javabinaries.fp";
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
#my $tertiodest="/u/kkdaadhi/Tertio_Dest";
my $tertiodest="/data/releases/tertio/7.6.0/patches";
# /* Global Environment Variables ******* /
sub main()
{
		createReadme();
		pkg();
		#createMail();
}
sub createReadme()
{
	open OP,"<$Bin/mrnumber.txt";
	$mrnumber=<OP>;
	close OP;
	open OP,"<$Bin/formattsks.txt";
	@formattsks=<OP>;
	$formattedtsks=join(",",@formattsks);
	$formattedtsks =~ s/[\n\r]//g;
	close OP;
	open OP,"<$Bin/synopsis.txt";
	@synopsis=<OP>;
	close OP;
	open OP,"<$Bin/summary_readme.txt";
	@summary=<OP>;
	close OP;
	open OP,"<$Bin/crresolv.txt";
	@crresolv=<OP>;
	close OP;
	open OP,"<$Bin/taskinfo.txt";
	@taskinfo=<OP>;
	close OP;
	open OP, "< $Bin/patchbinarylist.txt";
	@binarylist=<OP>;
	close OP;

	$mrnumber=~ s/^\s+|\s+$//g;
	open  FILE, "+> $Bin/tertio_7.6_README.txt";
	print FILE "Maintenance Release : Tertio $mrnumber build $build_number\n\n";
	print FILE "Created: $dt\n\n";
	print FILE "TASKS:$formattedtsks\n\n";
	print FILE "FIXES:@synopsis\n\n";
	print FILE "@binarylist\n\n";
	print FILE "TO INSTALL AND UNINSTALL:\nRefer Patch Release Notes.\n\nPRE-REQUISITE : 7.6.0\nSUPERSEDED : 7.6.2\n\nSUMMARY OF CHANGES:\nThe following changes have been delivered in this Maintenance Release.\n@summary ISSUES: None\n";
	close FILE;
}
sub createMail()
{
	@location_explode=map{"$_<br/>"} @location;
	open (my $FILE, "+> $Bin/releasenotes.html");
	print $FILE "<html><head><style>table {border: 1 solid black; white-space: nowrap; font: 12px arial, sans-serif;} body,td,th,tr {font: 12px arial, sans-serif; white-space: nowrap;}</style></head><body>";
	print $FILE "<table width=\"100%\" border=\"1\"<br/>";
	print $FILE "<tr><b><td>Product</td></b><td colspan=\'2\'>Tertio</td></tr><br/>";
	print $FILE "<tr><b><td>Release</td></b><td colspan=\'2\'>$mrnumber</td></tr><br/>";
	print $FILE "<tr><b><td>Build Number</td></b><td colspan=\'2\'>$build_number</td></tr><br/>";
	print $FILE "<tr><b><td>Release Type</td></b><td colspan=\'2\'>Maintenance Release</td></tr><br/>";
	print $FILE "<tr><b><td>Location</td></b><td colspan=\'2\'>@location_explode</td></tr><br/>";
	print $FILE "<tr><b><td>Build Date</td></b><td colspan=\'2\'>$dtformat</td></tr><br/>";
	print $FILE "<tr><b><td>Major changes in the new build</td></b><td colspan=\'2\'>BUG FIXES</td></tr><br/>";
	print $FILE "<tr><b><td>TOME</td></b><td>3.0.0</td><td>BUILD19</td></tr><br/>";
	print $FILE "<tr><b><td>Tertio ADK</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>CAF</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>Dashboard SDK</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>DDA Protocol Version</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>Menu Server Extension</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>SMS payload STK</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>RM CDK</td><td>-</td></b><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>PE CDK</td><td>-</td></b><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>Has the developer documentation been updated?</td></b><td colspan=\"2\">N/A</td></tr></table><br/>";
	print $FILE "<b>Installation instructions: </b><br/>";
	print $FILE "Same as previous Tertio Maintenance Release<br/><br/>";
	print $FILE "<b>Additional information about the changes:</b>N/A<br /><b>The Resolved CRs are:</b><br/>";
	print $FILE "<b><table width=\"100%\" border=\"1\">";
	print $FILE "<tr><b><td>CR ID</td><td>Synopsis</td><td>Request Type</td><td>Severity</td><td>Resolver</td><td>Priority</td></tr><br/>";
	foreach $cr(@crresolv)
	{
		($crid,$synopsis,$requesttype,$severity,$resolver,$priority)=split(/#/,$cr);
		print $FILE "<tr><b><td>$crid</td><td>$synopsis</td><td>$requesttype</td><td>$severity</td><td>$resolver</td><td>$priority</td></tr>";
	}
	print $FILE "</table><br/>";
	print $FILE "<b>The checked in tasks since the last build are:</b><br/>";
	print $FILE "<b><table width=\"100%\" border=\"1\">";
	print $FILE "<tr><b><td>Task ID</td><td>Synopsis</td><td>Resolver</td></tr>";
	foreach $tsk(@taskinfo)
	{
		($task_number,$task_synopsis,$task_resolver)=split(/#/,$tsk);
		print $FILE "<tr><b><td>$task_number</td><td>$task_synopsis</td><td>$task_resolver</td></tr><br/>";
	}
	print $FILE "</table><br/>";
	print $FILE "<b>Note:</b> To install Tertio $mrnumber, please use the latest PatchManager<br/></body></html>";
	close $FILE;
}

sub pkg()
{
	open LOCATION,">>$Bin/location.txt";
	foreach $prj(@projectlist)
	{
		rmtree($destdir);
		open OP, "< $binarylist";
  		@file_list=<OP>;
  		close OP;
  		my %deliveryhash;
  		$delroot="$dbbmloc/$prj/Provident_Dev/";
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
		foreach $key(keys %deliveryhash)
  		{
	  		$dirname=dirname($deliveryhash{$key});
				($filename,$permission)=split(/,/,$deliveryhash{$key});
  			mkpath("$destdir/$dirname");
				print "Permission of the file is: $permission\n";
  			copy("$key","$destdir/$filename") or die("Couldn't able to copy the file $!");
				chmod $permission,"$destdir/$filename";
  		}
  		chdir($destdir);
  		copy("$Bin/tertio_7.6_README.txt",$destdir);

  		if($prj =~ /linAS5/)
  		{
  			$hostos="rhel5";
  			$hostplatform="linAS5";
  			`find * -type f -name "*README.txt" | xargs tar cvf tertio-$mrnumber-$hostos-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$mrnumber-$hostos-build$build_number\.tar;gzip tertio-$mrnumber-$hostos-build$build_number\.tar;`;
  			print "tertio-$mrnumber-$hostos-build$build_number\.tar\.gz => $tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz";
  			copy("tertio-$mrnumber-$hostos-build$build_number\.tar\.gz","$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
  			push(@location,"$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz");
  			print LOCATION "$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostos-build$build_number\_$dtformat\.tar\.gz \n";

  		}
  		elsif($prj =~ /hpiav3/)
  		{
  			$hostplatform="hpiav3";
  			`find * -type f -name "*README.txt" | xargs tar cvf tertio-$mrnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$mrnumber-$hostplatform-build$build_number\.tar; /usr/contrib/bin/gzip tertio-$mrnumber-$hostplatform-build$build_number\.tar;`;
  			print "tertio-$mrnumber-$hostplatform-build$build_number\.tar\.gz => $tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz";
  			copy("tertio-$mrnumber-$hostplatform-build$build_number\.tar\.gz","$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
  			push(@location,"$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz");
  			print LOCATION "$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar\.gz  \n";
  		}
  		elsif($prj =~ /sol10/)
  		{
  			$hostplatform="sol10";
  			`find * -type f -name "*README.txt" | xargs tar cvf tertio-$mrnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$mrnumber-$hostplatform-build$build_number\.tar; gzip tertio-$mrnumber-$hostplatform-build$build_number\.tar;`;
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
