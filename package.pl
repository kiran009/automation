#!/usr/bin/perl
# Tertio 7.7 Build Script
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
my $gmake;
if($hostname !~ /pesthp2/)
{
	# On HPUX, CCM client doesn't exist, ignore setting this environment there
	$ENV{'CCM_HOME'}="/opt/ccm71";
	$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
	$CCM="$ENV{'CCM_HOME'}/bin/ccm";
}


#$result=GetOptions("devproject=s"=>\$devprojectname);
$result=GetOptions("hpuxproject=s"=>\$hpuxproject,"linuxproject=s"=>\$linuxproject,"solproject=s"=>\$solproject,"javaproject=s"=>\$javaprojectname,"folder=s"=>\$folder,"crs=s"=>\$crs);
if(!$result)
{
	print "Please provide devprojectname \n";
	exit;
}
if((!$hpuxproject) || (!$linuxproject) || (!$solproject) || (!$javaprojectname))
{
	print "You need to supply all projects \n";
	exit;
}
push(@projectlist,($hpuxproject,$linuxproject,$solproject));
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
my $hostname;
my @platforms;
my $workarea;
my @op;
my @file_list;
my $mrnumber;
#my $mailto='kiran.daadhi@evolving.com hari.annamalai@evolving.com Srikanth.Bhaskar@evolving.com anand.gubbi@evolving.com shreraam.gurumoorthy@evolving.com';
#my $mailto='kiran.daadhi@evolving.com';
my %hash;
$destdir="/u/kkdaadhi/Tertio_Deliverable";
my $readmeIssue;
@months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
@days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year+=1900;
my $dt="$mday $months[$mon] $year\n";
my @taskinfo,@synopsis,@summary,@crresolv,$formattsks;

# /* Global Environment Variables ******* /
sub main()
{	
		start_ccm();
		createMailnReadme();
		pkg();		
}

sub createMailnReadme()
{
	createReadme();
	createMail();
}

sub createReadme()
{
	open OP,"<$Bin/mrnumber.txt";
	$mrnumber=<OP>;
	close OP;
	open OP,"<$Bin/formattsks.txt";
	$formattsks=<OP>;
	close OP;
	open OP,"<$Bin/synopsis.txt";
	@synopsis=<OP>;
	close OP;
	open OP,"<$Bin/summary.txt";
	@summary=<OP>;
	close OP;
	open OP,"<$Bin/crresolv.txt";
	@crresolv=<OP>;
	close OP;
	open OP,"<$Bin/taskinfo.txt";
	@taskinfo=<OP>;
	close OP;
	
	$mrnumber=~ s/^\s+|\s+$//g;
	
	open  FILE, "+> $Bin/tertio-$mrnumber\_README.txt";
	print FILE "Maintenance Release : Tertio $mrnumber\n\n";
	print FILE "Created: $dt\n\n";
	print FILE "TASKS:$formattsks\n";
	print FILE "FIXES:@synopsis";
	print FILE "AFFECTS:";
	print FILE "TO INSTALL AND UNINSTALL:\nRefer Patch Release Notes.\n\nPRE-REQUISITE : 7.6.0\nSUPERSEDED : 7.6.2\n\nSUMMARY OF CHANGES:\nThe following changes have been delivered in this Maintenance Release.\n@summary ISSUES: None\n";
	close FILE;
	
}
sub createMail()
{
	open (my $FILE, "+> $Bin/releasenotes.html");
	print $FILE "<html><head><style>table,td,th,tr,body {border: 1px solid black; font: 12px arial, sans-serif;}</style></head><body>";
	print $FILE "<table width=\"100%\"<br/>"; 
	print $FILE "<tr><b><td>Product</td></b><td>Tertio</td></tr><br/>"; 
	print $FILE "<tr><b><td>Release</td></b><td>$mrnumber</td></tr><br/>";
	print $FILE "<tr><b><td>Build Number</td></b><td></td></tr><br/>";
	print $FILE "<tr><b><td>Release Type</td></b><td>Maintenance Release</td></tr><br/>";
	print $FILE "<tr><b><td>Location</td></b><td>?</td></tr><br/>";
	print $FILE "<tr><b><td>Build Date</td></b><td>?</td></tr><br/>";
	print $FILE "<tr><b><td>Major changes in the new build</td></b><td>?</td></tr><br/>";
	print $FILE "<tr><b><td>TOME</td></b><td>TOMEVERSION</td><td>TOMESUBVERSION</td></tr><br/>";
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
	print $FILE "<b>Additional information about the changes</b>N/A<br />The Resolved CRs are:<br/>";
	print $FILE "<b><table width=\"100%\" border=\"1\">";
	print $FILE "<tr><b><td>CR ID</td><td>Synopsis</td><td>Request Type</td><td>Severity</td><td>Resolver</td><td>Priority</td></tr><br/>";
	foreach $cr(@crresolv)
	{
		($crid,$synopsis,$requesttype,$severity,$resolver,$priority)=split(/#/,$cr);
		print $FILE "<tr><b><td>$crid</td><td>$synopsis</td><td>$requesttype</td><td>$severity</td><td>$resolver</td><td>$priority</td></tr>";
	}
	print $FILE "</table>";
	print $FILE "<b>The checked in tasks since the last build are:</b><br/>";
	print $FILE "<b><table width=\"100%\" border=\"1\">";
	print $FILE "<tr><b><td>Task ID</td><td>Synopsis</td><td>Resolver</td></tr></table><br/>";
	foreach $tsk(@taskinfo)
	{
		($task_synopsis,$task_resolver)=split(/#/,$cr);
		print $FILE "<tr><b><td>$task_synopsis</td><td>$task_resolver</td></tr><br/>";
	}
	print $FILE "<b>Note:</b> To install Tertio $mrnumber, please use the latest PatchManager<br/></body></html>";	
	close $FILE;
}

sub pkg()
{
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
  					$deliveryhash{$del[1]}=$del[1];
  				}
  				else
  				{
  					$deliveryhash{$del[1]}=$del[3];
  				}	
  			}
  			elsif($file =~ /DASHBOARDSRC/)
  			{
  				my @del=split(/\s+/,$file);
  				if($del[3] eq ".")
  				{
  					$deliveryhash{$del[1]}=$del[1];
  				}
  				else
  				{
  					$deliveryhash{$del[1]}=$del[3];
  				}	
  			}
  			else
  			{
  				my @del=split(/\s+/,$file);
  				if($del[3] eq ".")
  				{
	  				$deliveryhash{"$delroot/$del[1]"}=$del[1];
  				}
  				else
  				{
  					$deliveryhash{"$delroot/$del[1]"}=$del[3];
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
 	 			$deliveryhash{"$delroot/$del[1]"}=$del[1];
	  		}
  			else
  			{
	  			$deliveryhash{"$delroot/$del[1]"}=$del[3];
  			}
  		}
		foreach $key(keys %deliveryhash)
  		{
	  		$dirname=dirname($deliveryhash{$key});
  			mkpath("$destdir/$dirname");
  			copy("$key","$destdir/$deliveryhash{$key}") or die("Couldn't able to copy the file $!"); 	
  		}
  		if($prj =~ /linAS5/)
  		{
  			$hostplatform="linas5";
  		}
  		elsif($prj =~ /hpiav3/)
  		{
  			$hostplatform="hpiav3";
  		}
  		elsif($prj =~ /sol10/)
  		{
  			$hostplatform="sol10";
  		}
  		chdir($destdir);
  		`find ./ -type f | xargs tar cvf tertio-$mrnumber-$hostplatform\.tar; gzip tertio-$mrnumber-$hostplatform\.tar;`;
  		`zip -r $Bin/logs.zip $Bin/reconfigure_devproject_*.log $Bin/gmake_*.log`;
  		copy("tertio-$mrnumber-$hostplatform\.tar\.gz","/u/kkdaadhi/") or die("Couldn't copy to destination $!");
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