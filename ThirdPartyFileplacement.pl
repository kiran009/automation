#!/usr/bin/perl
# Tertio Fileplacement Script for Thirdparty file shipping
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
$result=GetOptions("crs=s"=>\$crs);
if(!$result)
{
	print "Please provide devprojectname \n";
	exit;
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

@crs=split(/,/,$crs);
print "The following list of CRs to the included in the patch:@crs\n";
# /* Global Environment Variables ******* /
sub main()
{
		start_ccm();
		getTasksnReadme();
		ccm_stop();
}

sub getTasksnReadme()
{
	open SYNOP,"+>$Bin/synopsis.txt";
	open SUMM,"+> $Bin/summary_readme.txt";
	open CRRESOLV, "+> $Bin/crresolv.txt";
	open TASKINF,"+>$Bin/taskinfo.txt";

	open COREFP, "+> $Bin/fileplacement.fp";
	open JAVAFP, "+> $Bin/javabinaries.fp";
	foreach $cr(@crs)
	{
		$cr=~ s/^\s+|\s+$//g;
		print "CRNumber is : $cr\n";
		$task_number=`$CCM query "is_associated_task_of(cvtype='problem' and problem_number='$cr')" -u -f "%task_number"`;
		$task_number=~ s/^\s+|\s+$//g;
		push(@tasks,$task_number);
		#get synopsis and other fields
		($synopsis)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%problem_synopsis"`;
		($requesttype)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%request_type"`;
		($severity)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%severity"`;
		($priority)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%priority"`;
		($resolver)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%resolver"`;
		($task_synopsis)=`$CCM task -show info $task_number -u -format "%task_synopsis"`;
		($task_resolver)=`$CCM task -show info $task_number -u -format "%resolver"`;
		@deliverable_list=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%deliverable_list"`;
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
		#fetch readme
		`$CCM query "cvtype=\'problem\' and problem_number=\'$cr\'"`;
    $patch_number=`$CCM query -u -f %patch_number`;
    $patch_readme=`$CCM query -u -f %patch_readme`;
    $patch_number=~ s/^\s+|\s+$//g;

		open OP, "+> $Bin/patchnumber.txt";
		print OP $patch_number;
		close OP;
    if($patch_readme =~ /N\/A/)
    {
    		print "The following CR: $cr doesn't have a README \n";
    }
    else
    {
    		open OP1,"+> $Bin/README.txt";
    		print OP1 $patch_readme;
    		close OP1;
    		`dos2unix $Bin/README.txt 2>&1 1>/dev/null`;
				`$Bin/updatePatchREADME.ksh $Bin/README.txt 2>&1 1>/dev/null`;
				copy("PROV_$patch_number\_README.txt","$patch_number\_README.txt");
    		@PatchFiles=`sed -n '/AFFECTS:/,/TO/ p' README.txt  | sed '\$ d' | sed '/^\$/d'`;
        push(@patchbinarylist,@PatchFiles);
        $sumreadme=`sed -n '/CHANGES:/,/ISSUES/ p' README.txt  | sed '\$ d' | grep -v 'CHANGES' | grep -v 'ISSUES' | sed '/^\$/d'`;
        print SUMM "CR$cr - $sumreadme\n";
    	}
	}
	close COREFP;
	close JAVAFP;
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
