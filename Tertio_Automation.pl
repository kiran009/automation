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
$ENV{'CCM_HOME'}="/opt/ccm71";
$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
$CCM="$ENV{'CCM_HOME'}/bin/ccm";
my $database="/data/ccmdb/provident/";
my $dbbmloc="/data/ccmbm/provident/";
my $binarylist="$Bin/fileplacement.fp";
my $javabinarylist="$Bin/javabinaries.fp";
my $hostname = hostname;
my $hostplatform;
if($hostname =~ /pedlinux5/)
{
	$hostplatform="linas5";
}
elsif($hostname =~ /pedlinux6/)
{
	$hostplatform="rhel6";
}
elsif($hostname =~ /pedsun2/)
{
	$hostplatform="sol10";	
}
elsif($hostname =~ /pesthp2/)
{
	$hostplatform="hpiav3";
}
$result=GetOptions("devproject=s"=>\$devprojectname,"javaproject=s"=>\$javaprojectname,"folder=s"=>\$folder,"crs=s"=>\$crs);
if(!$result)
{
	print "Please provide devprojectname, javaprojectname \n";
	exit;
}
if(!$devprojectname)
{
	print "Projectname is mandatory \n";
	exit;
}
if(!$folder)
{
	print "No folder is mentioned to add the TASKS corresponding to the above CRs, proceeding with existing one's\n";
}
if(!$crs)
{
	print "No extra CRs are provided for this build, proceeding with already added one's \n";	
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
my $hostname;
my @platforms;
my $workarea;
my @op;
my @file_list;
my $mr_number;
#my $mailto='kiran.daadhi@evolving.com hari.annamalai@evolving.com Srikanth.Bhaskar@evolving.com anand.gubbi@evolving.com shreraam.gurumoorthy@evolving.com';
my $mailto='kiran.daadhi@evolving.com';
my %hash;
$destdir="/u/kkdaadhi/Tertio_Deliverable";
my $readmeIssue;

@crs=split(/,/,$crs);
print "The following list of CRs to the included in the patch:@crs\n";
# /* Global Environment Variables ******* /
sub main()
{
	start_ccm();
	fetch_tasks();
	#fetch_readme();	
	reconfigure_dev_proj_and_compile();
	#reconfigure_del_project();
	delivery();
	send_email("Tertio $mr_number build is completed and available @ $destdir, logs are attached","/tmp/logs.zip");
	createhtml();
	#move_cr_status();
	ccm_stop();	
}
sub fetch_mrnumber($)
{
	my ($crnumber)=@_;
	$crnumber=~ s/^\s+|\s+$//g;
	print "CRnumber is: $crnumber \n";
	($mr_number)=`$CCM query "cvtype='problem' and problem_number='$crnumber'" -u -f "%MRnumber"`;
	$mr_number=~ s/^\s+|\s+$//g;		
	print "MRnumber for the patch is: $mr_number\n";
}
sub fetch_readme($)
{
	my ($crnumber)=@_;
	`$CCM query "cvtype=\'problem\' and problem_number=\'$crnumber\'"`;
    $patch_number=`$CCM query -u -f %patch_number`;
    $patch_readme=`$CCM query -u -f %patch_readme`;
    $patch_number=~ s/^\s+|\s+$//g;
    
    if($patch_readme =~ /N\/A/)
    {
    	print "The following CR doesn't have a README \n";
    }
    else
    {
    	#open OP,">> $binarylist";
    	open OP1,"+> $patch_number\_README.txt";
    	print OP1 $patch_readme;
    	close OP1;
    	`dos2unix $patch_number\_README.txt 2>&1 1>/dev/null`;
    	@PatchFiles=`sed -n '/AFFECTS/,/TO/ p' $patch_number\_README.txt  | sed '\$ d' | grep -v 'AFFECTS' | sed '/^\$/d'`;
    	print "Binary file list is: @PatchFiles \n";
        chomp(@PatchFiles);
        #print OP "@PatchFiles \n";
        #close OP;            	
    }		
}

sub fetch_tasks()
{
	
	foreach my $cr(@crs)
	{
		$cr=~ s/^\s+|\s+$//g;
		$task_number=`$CCM query "is_associated_task_of(cvtype='problem' and problem_number='$cr')" -u -f "%task_number"`;
		$task_number=~ s/^\s+|\s+$//g;
		push(@tasks,$task_number);
		print "List of Tasks associated with CR $cr => $task_number \n";
		@objectlist=`$CCM query "is_associated_object_of('$cr:task:probtrac')"`;
		print "List of objects associated with CR $cr are: @objectlist \n";
		$tasklist=join(",",@tasks);
		fetch_mrnumber($cr);		
		fetch_readme($cr);
	}	
	print "Consolidated tasklist for the patch is: $tasklist\n";
	open OP, "<$binarylist";
	@deliverablelist=<OP>;
	print "Consolidate deliverable list for the patch is: @deliverablelist \n";
	close OP;
}
sub reconfigure_dev_proj_and_compile()
{	
	$ccmworkarea=`$CCM wa -show -recurse $devprojectname`;
	($temp,$workarea)=split(/'/,$ccmworkarea);
	$workarea=~ s/^\s+|\s+$//g;
	$folder=~ s/^\s+|\s+$//g;
	print "***************CCM WorkArea is: $workarea***************\n";
	`$CCM folder -modify -add_task $tasklist $folder 2>&1 1>/tmp/task_addition_$devprojectname.log`;	
	umask 002;
	$devprojectname=~ s/^\s+|\s+$//g;
	print "Dev project name is :$devprojectname\n";
	`$CCM reconfigure -rs -r -p $devprojectname 2>&1 1>/tmp/reconfigure_devproject_$devprojectname.log`;
	open OP, "< /tmp/reconfigure_devproject_$devprojectname.log";
	@op=<OP>;
	close OP;
	if($devprojectname =~ /Java/)
	{
		chdir "$workarea/Provident_Java";
	}
	else
	{
		chdir "$workarea/Provident_Dev";
	}
	#`/usr/bin/gmake clean all 2>&1 1>/tmp/gmake_$devprojectname.log`;
	#open OP, "< /tmp/gmake_$devprojectname.log";
	#@op=<OP>;
	#close OP;		
}

sub createhtml()
{
	open (my $FILE, "+> releasenotes.html");
	print $FILE "<HTML>\n";
	print $FILE "<table width=\"100%\ border=\"1\">\n"; 
	print $FILE "<tr><td>Product</td><td>Tertio</td></tr>\n"; 
	print $FILE "<tr><td>Release</td><td>$mr_number</td></tr>\n";
	print $FILE "<tr><td>Build Number</td><td></td></tr>\n";
	print $FILE "<tr><td>Release Type</td><td>Maintenance Release</td></tr>\n";
	print $FILE "<tr><td>Location</td><td>?</td></tr>\n";
	print $FILE "<tr><td>Build Date</td><td>?</td></tr>\n";
	print $FILE "<tr><td>Major changes in the new build</td><td>?</td></tr>\n";
	print $FILE "<tr><td>TOME</td><td>TOMEVERSION</td><td>TOMESUBVERSION</td></tr>\n";
	print $FILE "<tr><td>Tertio ADK</td><td>-</td><td>-</td></tr>\n";
	print $FILE "<tr><td>CAF</td><td>-</td><td>-</td></tr>\n";
	print $FILE "<tr><td>Dashboard SDK</td><td>-</td><td>-</td></tr>\n";
	print $FILE "<tr><td>DDA Protocol Version</td><td>-</td><td>-</td></tr>\n";
	print $FILE "<tr><td>Menu Server Extension</td><td>-</td><td>-</td></tr>\n";
	print $FILE "<tr><td>SMS payload STK</td><td>-</td><td>-</td></tr>\n";
	print $FILE "<tr><td>RM CDK</td><td>-</td><td>-</td></tr>\n";
	print $FILE "<tr><td>PE CDK</td><td>-</td><td>-</td></tr>\n";
	print $FILE "<tr><td>Has the developer documentation been updated?</td><td colspan=\"2\">N/A</td></tr></table>\n";
	print $FILE "<b>Installation instructions: </b>\n";
	print $FILE "Same as previous Tertio Maintenance Release\n\n";
	print $FILE "<b>Additional information about the changes</b>N/A<br />The Resolved CRs are:\n";
	print $FILE "<b><table width=\"100%\" border=\"1\">";
	print $FILE "<tr><b><td>CR ID</td><td>Synopsis</td><td>Synopsis</td><td>Request Type</td><td>Severity</td><td>Resolver</td><td>Priority</td></tr></table>\n";
	print $FILE "<b>The checked in tasks since the last build are:</b>\n";
	print $FILE "<b><table width=\"100%\" border=\"1\">";
	print $FILE "<tr><b><td>Task ID</td><td>Synopsis</td><td>Resolver</td></tr></table>\n";
	print $FILE "<b>Note:</b> To install Tertio $mr_number, please use the latest PatchManager\n";	
	close $FILE;
}

sub delivery()
{
	rmtree($destdir);
	open OP, "< $binarylist";
  	@file_list=<OP>;
  	close OP;
  	my %deliveryhash;  
  	$delroot="$dbbmloc/$devprojectname/Provident_Dev/";
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
	  	print "Key is: $key and value is: $deliveryhash{$key} \n";
  		$dirname=dirname($deliveryhash{$key});
  		print "Dirname is: $dirname, creating directory $destdir/$dirname \n"; 
  		mkpath("$destdir/$dirname");
  		copy("$key","$destdir/$deliveryhash{$key}") or die("Couldn't able to copy the file $!"); 	
  	}
  	chdir($destdir);
  	`find ./ -type f | xargs tar uvf tertio-$mr_number-$hostplatform\.tar; gzip tertio-$mr_number-$hostplatform\.tar;`;
  	`zip -r /tmp/logs.zip /tmp/reconfigure_devproject_$devprojectname.log /tmp/gmake_$devprojectname.log`; 
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
sub send_email()
{
	($subject,$attachment)=@_;
	print "\$attachment value is: $attachment \n";
	system("/usr/bin/mutt -s '$subject' $mailto -a $attachment < /dev/null");
}
main();

#  exit;
 # print "Create tar bundle for the platform \n";
  #if($devprojectname =~ /Java/)
  #{
#	$delroot="$dbbmloc/$devprojectname/Provident_Delivery";
#  }
 # else
  #{  	
  #	$delroot="$dbbmloc/$devprojectname/Provident_Dev/";
  #	print "Delivery root is: $delroot \n";
  #}
  
 # mkdir("$destdir",0755);
 # foreach $file(@file_list)
 # {
 # 	$file=~ s/\$PROVHOME//g;
 # 	$file=~ s/^\s+|\s+$//g;
 # 	if($file =~ /jar/)
 # 	{
 # 		
 # 	}
 # 	if($file =~ /mr_/)
 # 	{
 # 		($destfile=$file) =~ s/mr_/$mr_number/g;
 # 		$destfile=~ s/^\s+|\s+$//g;
 # 		copy("$delroot/$file","$destdir/$destfile") or die("Couldn't able to copy $file \n");
 # 	}
 # 	copy("$delroot/$file","$destdir") or die("Couldn't able to copy $file \n");
 # }