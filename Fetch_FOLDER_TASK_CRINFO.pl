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

$result=GetOptions("folder_762a=s"=>\$f_762a,"folder_762c=s"=>\$f_762c,"folder_763a=s"=>\$f_763a);

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
my $hostname;
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
my @tasks_762c,@tasks_763a,@crs_762a,@crs_762c,@crs_763a;
my @uniq762a,@uniq762c,@uniq763a;
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
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_762a,$crinfo);		
	}
	@uniq762a = do { my %seen; grep { !$seen{$_}++ } @crs_762a};
	foreach $task(@tasks_762c)
	{
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_762c,$crinfo);
	}
	@uniq762c = do { my %seen; grep { !$seen{$_}++ } @crs_762c};
	foreach $task(@tasks_763a)
	{
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_763a,$crinfo);
	}
	@uniq763a = do { my %seen; grep { !$seen{$_}++ } @crs_763a};
	
	print "Uniq CRs in 7.6.2.a are: @uniq762a \nUniq CRs in 7.6.2.c are: @uniq762c \nUniq CRs in 7.6.3.a are: @uniq763a\n";
	
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

sub getTasksnReadme()
{	
	open SYNOP,"+>$Bin/synopsis.txt";
	open SUMM,"+> $Bin/summary_readme.txt";
	open CRRESOLV, "+> $Bin/crresolv.txt";
	open TASKINF,"+>$Bin/taskinfo.txt";
	
	foreach $cr(@crs)
	{
		$cr=~ s/^\s+|\s+$//g;
		print "CRNumber is : $cr\n";
		$task_number=`$CCM query "is_associated_task_of(cvtype='problem' and problem_number='$cr')" -u -f "%task_number"`;
		$task_number=~ s/^\s+|\s+$//g;
		push(@tasks,$task_number);		
		#get mrnumber, synopsis and other fields
		($mr_number)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%MRnumber"`;
		($synopsis)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%problem_synopsis"`;
		($requesttype)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%request_type"`;
		($severity)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%severity"`;
		($priority)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%priority"`;
		($resolver)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%resolver"`;
		($task_synopsis)=`$CCM task -show info $task_number -u -format "%task_synopsis"`;
		($task_resolver)=`$CCM task -show info $task_number -u -format "%resolver"`;
		$synopsis=~ s/^\s+|\s+$//g;
		$requesttype=~ s/^\s+|\s+$//g;
		$severity=~ s/^\s+|\s+$//g;
		$resolver=~ s/^\s+|\s+$//g;
		$task_synopsis=~ s/^\s+|\s+$//g;
		$task_resolver=~ s/^\s+|\s+$//g;
		$priority=~ s/^\s+|\s+$//g;		
		print CRRESOLV "$cr#$synopsis#$requesttype#$severity#$resolver#$priority\n";
		print TASKINF "$task_number#$task_synopsis#$task_resolver\n";
		print SYNOP "CR$cr $synopsis\n";
		$mr_number=~ s/^\s+|\s+$//g;
		open MR,"+> $Bin/mrnumber.txt";
		print MR "$mr_number";
		close MR;
		#fetch readme
		`$CCM query "cvtype=\'problem\' and problem_number=\'$cr\'"`;
    	$patch_number=`$CCM query -u -f %patch_number`;
    	$patch_readme=`$CCM query -u -f %patch_readme`;
    	$patch_number=~ s/^\s+|\s+$//g;
    	
    	
    	if($patch_readme =~ /N\/A/)
    	{
    		print "The following CR: $cr doesn't have a README \n";
    	}
    	else
    	{
       		open OP1,"+> $Bin/$patch_number\_README.txt";
    		print OP1 $patch_readme;
    		close OP1;
    		`dos2unix $Bin/$patch_number\_README.txt 2>&1 1>/dev/null`; 
    		@PatchFiles=`sed -n '/AFFECTS:/,/TO/ p' $patch_number\_README.txt  | sed '\$ d' | sed '/^\$/d'`;
    		
    		#print "Binary file list is: @PatchFiles \n";
        	#chomp(@PatchFiles);
        	#my @newPatchFiles;  
        	#foreach my $patchfile(@PatchFiles)
        	#{
        	#	$newpatchfile=($patchfile=~s/mr_/$mr_number\_/g);
        	#	push(@newPatchFiles, $newpatchfile);
        	#}
        	push(@patchbinarylist,@PatchFiles);
        	$sumreadme=`sed -n '/CHANGES:/,/ISSUES/ p' $patch_number\_README.txt  | sed '\$ d' | grep -v 'CHANGES' | grep -v 'ISSUES' | sed '/^\$/d'`;
        	print SUMM "CR$cr - $sumreadme\n";    	
    	}
	}	
		
	my @uniqbinlist = do { my %seen; grep { !$seen{$_}++ } @patchbinarylist};
	open OP, "+> $Bin/patchbinarylist.txt";
	print OP @uniqbinlist;
	#
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
