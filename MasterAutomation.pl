#!/usr/bin/perl
# Tertio 7.X Build Script
use Cwd;
use File::Path;
use File::Find;
use File::Basename;
use Switch;
use Getopt::Long;
use File::Copy;
use FindBin qw($Bin);
use lib qw("$Bin/../lib" "$Bin");
use Sys::Hostname;

#/************ Setting Environment Variables *******************/
$ENV{'CCM_HOME'}="/opt/ccm71";
$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
$CCM="$ENV{'CCM_HOME'}/bin/ccm";
my $database="/data/ccmdb/provident/";
my $dbbmloc="/data/ccmbm/provident/";
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

$result=GetOptions("devprojects=s"=>\$devprojectlist,"folder=s"=>\$folder,"crs=s"=>\$crs);
if(!$result)
{
	print "Please provide devprojectname \n";
	exit;
}
if(!$devprojectlist)
{
	print "Projectlist is mandatory \n";
	exit;
}
if(!$folder)
{
	print "No folder is mentioned to add the TASKS corresponding to the above CRs, proceeding with existing one's\n";
	exit;
}
if(!$crs)
{
	print "No extra CRs are provided for this build, proceeding with already added one's \n";
	exit;
}
@devprojects=split(/;/,$devprojectlist);
my @PatchFiles;
my @files;
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
my $mr_number;
my @patchbinarylist;
my $cr;
my %hash;
my $readmeIssue;
my @consumreadme;

@crs=split(/,/,$crs);
print "The following list of CRs to the included in the patch:@crs\n";
# /* Global Environment Variables ******* /
sub main()
{
		start_ccm();
		getTasksnReadme();
		foreach $devprojectname(@devprojects)
		{
		    reconfigure_devproject($devprojectname);
		}
		ccm_stop();
}
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
		@tasklist=`$CCM query "is_associated_task_of(cvtype='problem' and problem_number='$cr')" -u -f "%task_number"`;
		#$task_number=~ s/^\s+|\s+$//g;
		push(@tasks,@tasklist);
		#get mrnumber, synopsis and other fields
		($mr_number)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%MRnumber"`;
		($synopsis)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%problem_synopsis"`;
		($requesttype)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%request_type"`;
		($severity)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%severity"`;
		($priority)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%priority"`;
		($resolver)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%resolver"`;
		$synopsis=~ s/^\s+|\s+$//g;
		$requesttype=~ s/^\s+|\s+$//g;
		$severity=~ s/^\s+|\s+$//g;
		$resolver=~ s/^\s+|\s+$//g;
		foreach $task_number(@tasklist)
		{
			$task_number=~ s/^\s+|\s+$//g;
			print "Task number is: $task_number \n";
			print "$CCM task -show info $task_number -u -f '%task_synopsis'";
			print "$CCM task -show info $task_number -u -f '%resolver'";
			($task_synopsis)=`$CCM task -show info $task_number -f "%task_synopsis"`;
			($task_resolver)=`$CCM task -show info $task_number -f "%resolver"`;
			$task_synopsis=~ s/^\s+|\s+$//g;
			$task_resolver=~ s/^\s+|\s+$//g;
			print TASKINF "$task_number#$task_synopsis#$task_resolver\n";
		}
		$priority=~ s/^\s+|\s+$//g;
		print CRRESOLV "$cr#$synopsis#$requesttype#$severity#$resolver#$priority\n";
		print SYNOP "CR$cr $synopsis\n";
		$mr_number=~ s/^\s+|\s+$//g;
		print "MRNumber is: $mr_number \n";
		open MR,"+> $Bin/mrnumber.txt";
		print MR "$mr_number";
		close MR;
		#fetch readme
		`$CCM query "cvtype=\'problem\' and problem_number=\'$cr\'"`;
        $patch_readme=`$CCM query -u -f %patch_readme`;

    	if($patch_readme =~ /N\/A/)
    	{
    		print "The following CR: $cr doesn't have a README \n";
    	}
    	else
    	{
       		open OP1,"+> $Bin/$cr\_README.txt";
    		print OP1 $patch_readme;
    		close OP1;
    		`dos2unix $Bin/$cr\_README.txt 2>&1 1>/dev/null`;
    		@PatchFiles=`sed -n '/AFFECTS:/,/TO/ p' $cr\_README.txt  | sed '\$ d' | sed '/^\$/d'`;
        	push(@patchbinarylist,@PatchFiles);
        	$sumreadme=`sed -n '/CHANGES:/,/ISSUES/ p' $cr\_README.txt  | sed '\$ d' | grep -v 'CHANGES' | grep -v 'ISSUES' | sed '/^\$/d'`;
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
	print "Tasks are: @tasks \n";
	chomp(@tasks);
	chomp(@tasks);
	$tasklist=join(",",@tasks);
	$tasklist=~ s/\s+//g;
	print "Tasklist is: $tasklist \n";
	@formattsks=join("\n", map { 'PROV_' . $_ } @tasks);
	open OP,"+>$Bin/formattsks.txt";
	print OP @formattsks;
	close OP;
}

sub reconfigure_devproject($)
{
    ($devprojectname)=@_;
    print "Reconfiguring Devproject: $devprojectname \n";
	$ccmworkarea=`$CCM wa -show -recurse $devprojectname`;
	($temp,$workarea)=split(/'/,$ccmworkarea);
	$workarea=~ s/^\s+|\s+$//g;
	$folder=~ s/^\s+|\s+$//g;
	$devprojectname=~ s/^\s+|\s+$//g;
	`$CCM folder -modify -add_task $tasklist $folder 2>&1 1>$Bin/task_addition_$devprojectname.log`;
	umask 002;
	`$CCM reconfigure -rs -r -p $devprojectname 2>&1 1>$Bin/reconfigure_$devprojectname.log`;
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
	# Nullify the location.txt file
	`> $Bin/location.txt`;
}

main();
