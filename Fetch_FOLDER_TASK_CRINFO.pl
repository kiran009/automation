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
{	$hostplatform="linas5";}
elsif($hostname =~ /pedlinux6/)
{	$hostplatform="rhel6";}
elsif($hostname =~ /pedsun2/)
{	$hostplatform="sol10";}
elsif($hostname =~ /pesthp2/)
{	$hostplatform="hpiav3";}

my $result=GetOptions("folder_762a=s"=>\$f_762a,"folder_762c=s"=>\$f_762c,"folder_763a=s"=>\$f_763a);
#  Executing instructions: perl Fetch_FOLDER_TASK_CRINFO.pl -folder_762a 1409 -folder_762c 1413 -folder_763a 1431
my @PatchFiles;
my @files;
my $patch_number;
my $problem_number;

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
my $mr_number;
my @patchbinarylist;
my $cr;
#my $mailto='kiran.daadhi@evolving.com hari.annamalai@evolving.com Srikanth.Bhaskar@evolving.com anand.gubbi@evolving.com shreraam.gurumoorthy@evolving.com';
my $mailto='kiran.daadhi@evolving.com';
my %hash;
my $readmeIssue;
my @consumreadme;
my @tasks_762a;
my (@tasks_762c,@tasks_763a,@crs_762a,@crs_762c,@crs_763a);
my (@uniq762a,@uniq762c,@uniq763a);
my $destdir="/u/kkdaadhi/Tertio_Deliverable";
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
# /* Global Environment Variables ******* /
sub main()
{	
		start_ccm();
		listfolderTasks();
		#listTaskCRs();
		ccm_stop();		
}
sub listfolderTasks()
{
	@tasks_762a=`$CCM folder -show tasks '$f_762a' -u -f "%task_number"`;
	@tasks_762c=`$CCM folder -show tasks '$f_762c' -u -f "%task_number"`;
	@tasks_763a=`$CCM folder -show tasks '$f_763a' -u -f "%task_number"`;
	
	print "Tasks in 7.6.2.a are => @tasks_762a \n\n";
	print "Tasks in 7.6.2.c are => @tasks_762c \n\n";
	print "Tasks in 7.6.3.a are => @tasks_763a \n\n";
	foreach $task(@tasks_762a)
	{
		$task=~ s/^\s+|\s+$//g;
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_762a,$crinfo);		
	}
	@uniq762a = do { my %seen; grep { !$seen{$_}++ } @crs_762a};
	foreach $task(@tasks_762c)
	{
		$task=~ s/^\s+|\s+$//g;
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_762c,$crinfo);
	}
	@uniq762c = do { my %seen; grep { !$seen{$_}++ } @crs_762c};
	foreach $task(@tasks_763a)
	{
		$task=~ s/^\s+|\s+$//g;
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_763a,$crinfo);
	}
	@uniq763a = do { my %seen; grep { !$seen{$_}++ } @crs_763a};
	
	print "Uniq CRs in 7.6.2.a are: @uniq762a \nUniq CRs in 7.6.2.c are: @uniq762c \nUniq CRs in 7.6.3.a are: @uniq763a\n";
	getTasksnReadme(@uniq762a);
	createReadme();
	getTasksnReadme(@uniq762c);
	createReadme();
	getTasksnReadme(@uniq763a);
	createReadme();		
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

sub createMail()
{
	open (my $FILE, "+> $Bin/releasenotes_test.html");
	print $FILE "<html><head><style>table {border: 1 solid black; white-space: nowrap; font: 12px arial, sans-serif;} body,td,th,tr {font: 12px arial, sans-serif; white-space: nowrap;}</style></head><body>";
	print $FILE "<table width=\"100%\" border=\"1\"<br/>"; 
	print $FILE "<tr><b><td>Product</td></b><td colspan=\'2\'>Tertio</td></tr><br/>"; 
	print $FILE "<tr><b><td>Release</td></b><td colspan=\'2\'>$mrnumber</td></tr><br/>";	
	print $FILE "<tr><b><td>Release Type</td></b><td colspan=\'2\'>Maintenance Release</td></tr><br/>";
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

sub createReadme()
{
	#open OP,"<$Bin/mrnumber.txt";
	#$mrnumber=<OP>;
	#close OP;
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
	open  FILE, ">> $Bin/tertio_7.6_TESTREADME.txt";	
	print FILE "Created: $dt\n\n";
	print FILE "TASKS:$formattedtsks\n\n";
	print FILE "FIXES:@synopsis\n\n";
	print FILE "@binarylist\n\n";
	print FILE "TO INSTALL AND UNINSTALL:\nRefer Patch Release Notes.\n\nPRE-REQUISITE : 7.6.0\nSUPERSEDED : 7.6.2\n\nSUMMARY OF CHANGES:\nThe following changes have been delivered in this Maintenance Release.\n@summary ISSUES: None\n";
	close FILE;	
}
sub getTasksnReadme()
{	
	my @crs=@_;
	open SYNOP,"+>$Bin/synopsis.txt";
	open SUMM,"+> $Bin/summary_readme.txt";
	open CRRESOLV, "+> $Bin/crresolv.txt";
	open TASKINF,"+>$Bin/taskinfo.txt";
	
	foreach $cr(@crs)
	{
		$cr=~ s/^\s+|\s+$//g;
		print "CRNumber is : $cr\n";
		@task_numbers=`$CCM query "is_associated_task_of(cvtype='problem' and problem_number='$cr')" -u -f "%task_number"`;		
		push(@tasks,@task_numbers);		
		#get mrnumber, synopsis and other fields
		($mr_number)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%MRnumber"`;
		($synopsis)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%problem_synopsis"`;
		($requesttype)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%request_type"`;
		($severity)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%severity"`;
		($priority)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%priority"`;
		($resolver)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%resolver"`;
		foreach $task_number(@task_numbers)
		{
			($task_synopsis)=`$CCM task -show info $task_number -u -format "%task_synopsis"`;
			($task_resolver)=`$CCM task -show info $task_number -u -format "%resolver"`;
			print TASKINF "$task_number#$task_synopsis#$task_resolver\n";
		}
		$synopsis=~ s/^\s+|\s+$//g;
		$requesttype=~ s/^\s+|\s+$//g;
		$severity=~ s/^\s+|\s+$//g;
		$resolver=~ s/^\s+|\s+$//g;
		$task_synopsis=~ s/^\s+|\s+$//g;
		$task_resolver=~ s/^\s+|\s+$//g;
		$priority=~ s/^\s+|\s+$//g;		
		print CRRESOLV "$cr#$synopsis#$requesttype#$severity#$resolver#$priority\n";		
		print SYNOP "CR$cr $synopsis\n";
		#$mr_number=~ s/^\s+|\s+$//g;
		#open MR,"+> $Bin/mrnumber.txt";
		#print MR "$mr_number";
		#close MR;
		#fetch readme
		`$CCM query "cvtype=\'problem\' and problem_number=\'$cr\'"`;
    	$patch_number=`$CCM query -u -f %patch_number`;
    	$patch_readme=`$CCM query -u -f %patch_readme`;
    	$patch_number=~ s/^\s+|\s+$//g;    	
    	$patch_number =~ s/\s+/_/g;
    	if(($patch_readme =~ /N\/A/) || (not defined $patch_readme))
    	{
    		print "The following CR: $cr doesn't have a README \n";
    	}
    	else
    	{
    		if(($cr =~ /4291/) || ($cr =~ /4493/) || ($cr =~ /4500/) || ($cr =~ /4505/) || ($cr =~ /4575/) || ($cr =~ /4596/) || ($cr =~ /4606/) || ($cr =~ /4609/))
    		{
    			open OP1,"+> $Bin/$patch_number\_README.txt";
    			print OP1 $patch_readme;
    			close OP1;
    			`dos2unix $Bin/$patch_number\_README.txt 2>&1 1>/dev/null`; 
    			@PatchFiles=`sed -n '/AFFECTS:/,/TO/ p' $patch_number\_README.txt  | sed '\$ d' | sed '/^\$/d'`;
    			print "PatchFiles information is : @PatchFiles \n";   		
    		
        		push(@patchbinarylist,@PatchFiles);
        		$sumreadme=`sed -n '/AFFECTED:/,/ISSUES/ p' $patch_number\_README.txt  | sed '\$ d' | grep -v 'AFFECTED' | grep -v 'ISSUES' | sed '/^\$/d'`;
        		print SUMM "CR$cr - $sumreadme\n";
        		print "Summary from README is: $sumreadme\n";
    		}
    		else
    		{ 
       			open OP1,"+> $Bin/$patch_number\_README.txt";
    			print OP1 $patch_readme;
    			close OP1;
    			`dos2unix $Bin/$patch_number\_README.txt 2>&1 1>/dev/null`; 
    			@PatchFiles=`sed -n '/AFFECTS:/,/TO/ p' $patch_number\_README.txt  | sed '\$ d' | sed '/^\$/d'`;   		
    			print "PatchFiles information is : @PatchFiles \n";
    			
	        	push(@patchbinarylist,@PatchFiles);
        		$sumreadme=`sed -n '/CHANGES:/,/ISSUES/ p' $patch_number\_README.txt  | sed '\$ d' | grep -v 'CHANGES' | grep -v 'ISSUES' | sed '/^\$/d'`;
        		print SUMM "CR$cr - $sumreadme\n";
        		print "Summary from README is: $sumreadme\n";
    		}    	
    	}
	}	
		
	my @uniqbinlist = do { my %seen; grep { !$seen{$_}++ } @patchbinarylist};
	open OP, "+> $Bin/patchbinarylist.txt";
	print OP @uniqbinlist;	
	close OP;
	close SUMM;
	close SYNOP;
	close CRRESOLV;
	close TASKINF;	
	$tasklist=join(",",@tasks);
	@formattsks=join("\n", map { 'PROV_' . $_ } @tasks);
	open OP,"+>$Bin/formattsks.txt";
	print OP @formattsks;
	close OP;	
}