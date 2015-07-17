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

#/************ Setting Environment Variables *******************/
$ENV{'CCM_HOME'}="/opt/ccm71";
$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
$CCM="$ENV{'CCM_HOME'}/bin/ccm";
my $database="/data/ccmdb/provident/";
my $dbbmloc="/data/ccmbm/provident/";
my $binarylist="$Bin/Tertio_7.7.0.1.fp";
$result=GetOptions("devproject=s"=>\$devprojectname,"delproject=s"=>\$delprojectname,"folder=s"=>\$folder,"crs=s"=>\$crs,"buildnumber=s"=>\$build_number);
if(!$result)
{
	print "Please provide devprojectname, delprojectname \n";
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
my $mailto='kiran.daadhi@evolving.com Srikanth.Bhaskar@evolving.com';
my %hash;
$destdir="/u/kkdaadhi/Tertio_Deliverable";
my $readmeIssue;
my @location;

@months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
@days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year+=1900;
my $dt="$mday $months[$mon] $year\n";
my @taskinfo,@synopsis,@summary,@crresolv,@formattsks,@binarylist;
my $dtformat="$year$months[$mon]$mday\_$hour\:$min";
@crs=split(/,/,$crs);
print "The following list of CRs to the included in the patch:@crs\n";
# /* Global Environment Variables ******* /
sub main()
{
	start_ccm();
	getTasksnReadme();		
	reconfigure_dev_proj_and_compile();
	createReadme();
	pkg();
	createMail();
	#send_email("Tertio $mr_number build is completed and available @ $destdir, logs are attached","/tmp/logs.zip");
	#move_cr_status();
	ccm_stop();	
}


sub getTasksnReadme()
{	
	open SYNOP,"+>$Bin/synopsis.txt";
	open SUMM,"+> $Bin/summary.txt";
	open CRRESOLV, "+> $Bin/crresolv.txt";
	open TASKINF,"+>$Bin/taskinfo.txt";
	
	foreach my $cr(@crs)
	{
		$cr=~ s/^\s+|\s+$//g;
		$task_number=`$CCM query "is_associated_task_of(cvtype='problem' and problem_number='$cr')" -u -f "%task_number"`;
		$task_number=~ s/^\s+|\s+$//g;
		push(@tasks,$task_number);		
		#get mrnumber, synopsis and summary
		($mr_number)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%MRnumber"`;
		($synopsis)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%problem_synopsis"`;
		($summary)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%problem_description"`;
		($requesttype)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%request_type"`;
		($severity)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%severity"`;
		($priority)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%priority"`;
		($resolver)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%resolver"`;
		($task_synopsis)=`$CCM task -show info $task_number -u -format "%task_synopsis"`;
		($task_resolver)=`$CCM task -show info $task_number -u -format "%resolver"`;
		$synopsis=~ s/^\s+|\s+$//g;
		$summary=~ s/^\s+|\s+$//g;
		$requesttype=~ s/^\s+|\s+$//g;
		$severity=~ s/^\s+|\s+$//g;
		$resolver=~ s/^\s+|\s+$//g;
		$task_synopsis=~ s/^\s+|\s+$//g;
		$task_resolver=~ s/^\s+|\s+$//g;
		$priority=~ s/^\s+|\s+$//g;		
		print CRRESOLV "$cr#$synopsis#$requesttype#$severity#$resolver#$priority\n";
		print TASKINF "$task_number#$task_synopsis#$task_resolver\n";
		print SYNOP "CR$cr $synopsis\n";
		print SUMM "CR$cr $summary\n";
		$mr_number=~ s/^\s+|\s+$//g;
		open MR,"+> $Bin/mrnumber.txt";
		print MR "$mr_number";
		close MR;
		#fetch readme
		`$CCM query "cvtype=\'problem\' and problem_number=\'$cr\'"`;
    	$patch_number=`$CCM query -u -f %patch_number`;
    	$patch_readme=`$CCM query -u -f %patch_readme`;
    	$patch_number=~ s/^\s+|\s+$//g;
    	
    	open README, "+> $Bin/summary_readme.txt";
    	if($patch_readme =~ /N\/A/)
    	{
    		print "The following CR doesn't have a README \n";
    	}
    	else
    	{
       		open OP1,"+> $Bin/$patch_number\_README.txt";
    		print OP1 $patch_readme;
    		close OP1;
    		`dos2unix $Bin/$patch_number\_README.txt 2>&1 1>/dev/null`; 
    		@PatchFiles=`sed -n '/AFFECTS:/,/TO/ p' $patch_number\_README.txt  | sed '\$ d' | grep -v 'AFFECTS' | sed '/^\$/d'`;
    		#print "Binary file list is: @PatchFiles \n";
        	#chomp(@PatchFiles);  
        	push(@patchbinarylist,@PatchFiles);
        	@sumreadme=`sed -n '/AFFECTED:/,/ISSUES/ p' $patch_number\_README.txt  | sed '\$ d' | grep -v 'AFFECTED' | sed '/^\$/d'`;
        	print README "$cr#@sumreadme";    	
    	}
	}
	open OP, "+> $Bin/patchbinarylist.txt";
	print OP @patchbinarylist;
	close OP;
	
	close README;
	
	close SYNOP;
	close SUMM;
	close CRRESOLV;
	close TASKINF;
	#close MR;
	$tasklist=join(",",@tasks);
	@formattsks=join("\n", map { 'PROV_' . $_ } @tasks);
	open OP,"+>$Bin/formattsks.txt";
	print OP @formattsks;
	close OP;	
}
sub createReadme()
{
	open OP,"<$Bin/mrnumber.txt";
	$mrnumber=<OP>;
	close OP;
	open OP,"<$Bin/formattsks.txt";
	@formattsks=<OP>;
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
	open OP, "< $Bin/patchbinarylist.txt";
	@binarylist=<OP>;
	close OP;
	
	
	$mrnumber=~ s/^\s+|\s+$//g;
	
	open  FILE, "+> $Bin/tertio-$mrnumber\_README.txt";
	print FILE "Maintenance Release : Tertio $mrnumber build $build_number\n\n";
	print FILE "Created: $dt\n\n";
	print FILE "TASKS:@formattsks\n";
	print FILE "FIXES:@synopsis";
	print FILE "AFFECTS:@binarylist";
	print FILE "TO INSTALL AND UNINSTALL:\nRefer Patch Release Notes.\n\nPRE-REQUISITE : 7.6.0\nSUPERSEDED : 7.6.2\n\nSUMMARY OF CHANGES:\nThe following changes have been delivered in this Maintenance Release.\n@summary ISSUES: None\n";
	close FILE;
	
}
sub createMail()
{
	open (my $FILE, "+> $Bin/releasenotes.html");
	print $FILE "<html><head><style>table {border: 1 solid black; white-space: nowrap; font: 12px arial, sans-serif;} body,td,th,tr {font: 12px arial, sans-serif; white-space: nowrap;}</style></head><body>";
	print $FILE "<table width=\"100%\" border=\"1\"<br/>"; 
	print $FILE "<tr><b><td>Product</td></b><td colspan=\'2\'>Tertio</td></tr><br/>"; 
	print $FILE "<tr><b><td>Release</td></b><td colspan=\'2\'>$mrnumber</td></tr><br/>";
	print $FILE "<tr><b><td>Build Number</td></b><td colspan=\'2\'>$build_number</td></tr><br/>";
	print $FILE "<tr><b><td>Release Type</td></b><td colspan=\'2\'>Maintenance Release</td></tr><br/>";
	print $FILE "<tr><b><td>Location</td></b><td colspan=\'2\'>@location</td></tr><br/>";
	print $FILE "<tr><b><td>Build Date</td></b><td colspan=\'2\'>$dtformat</td></tr><br/>";
	print $FILE "<tr><b><td>Major changes in the new build</td></b><td colspan=\'2\'>?</td></tr><br/>";
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
sub reconfigure_devproject()
{	
	$ccmworkarea=`$CCM wa -show -recurse $devprojectname`;
	($temp,$workarea)=split(/'/,$ccmworkarea);
	$workarea=~ s/^\s+|\s+$//g;
	$folder=~ s/^\s+|\s+$//g;
	`$CCM folder -modify -add_task $tasklist $folder 2>&1 1>$Bin/task_addition_$devprojectname.log`;	
	umask 002;
	$devprojectname=~ s/^\s+|\s+$//g;
	`$CCM reconfigure -rs -r -p $devprojectname 2>&1 1>$Bin/reconfigure_devproject_$devprojectname.log`;	
}

sub reconfigure_dev_proj_and_compile()
{	
	$ccmworkarea=`$CCM wa -show -recurse $devprojectname`;
	($temp,$workarea)=split(/'/,$ccmworkarea);
	$workarea=~ s/^\s+|\s+$//g;
	$folder=~ s/^\s+|\s+$//g;	
	`$CCM folder -modify -add_task $tasklist $folder 2>&1 1>$Bin/task_addition_$devprojectname.log`;	
	umask 002;
	$devprojectname=~ s/^\s+|\s+$//g;
	`$CCM reconfigure -rs -r -p $devprojectname 2>&1 1>$Bin/reconfigure_devproject_$devprojectname.log`;	
	if($devprojectname =~ /Java/)
	{
		chdir "$workarea/Provident_Java";
	}
	else
	{
		chdir "$workarea/Provident_Dev";
	}
	`/usr/bin/gmake clean all 2>&1 1>/$Bin/gmake_$devprojectname.log`;			
}




sub pkg()
{
	rmtree($destdir);
	open OP, "< $binarylist";
	@file_list=<OP>;
	close OP;
	my %deliveryhash;  
	$delroot="$dbbmloc/$devprojectname/Provident_Dev/";
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
  		chdir($destdir);
  		copy("$Bin/tertio-$mrnumber\_README.txt",$destdir);
  	
  			$hostos="rhel6";
  			$hostplatform="RHEL6";
  			`find ./ -type f | xargs tar cvf tertio-$mrnumber-$hostos\.tar; gzip tertio-$mrnumber-$hostos\.tar;`;  			
  			copy("tertio-$mrnumber-$hostos\.tar\.gz","/data/releases/tertio/7.7.0/patches/$hostplatform/NotTested/tertio-$mrnumber-$hostos\_$dtformat\.tar\.gz") or die("Couldn't copy to destination $!");
  			push(@location,"/data/releases/tertio/7.7.0/patches/$hostplatform/NotTested/tertio-$mrnumber-$hostos\_$dtformat\.tar\.gz");
  	  		`zip -r $Bin/logs.zip $Bin/reconfigure_devproject_*.log`;
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