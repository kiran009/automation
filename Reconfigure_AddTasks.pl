#!/usr/bin/perl
# DSA Build Automation Script
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
use List::MoreUtils qw( minmax );
my ($min, $max);

#/************ Setting Environment Variables *******************/
$ENV{'CCM_HOME'}="/opt/ccm71";
$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
$CCM="$ENV{'CCM_HOME'}/bin/ccm";
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

$result=GetOptions("project=s"=>\$projectname,"database=s"=>\$db,"folder=s"=>\$folder,"crs=s"=>\$crs);
if(!$result)
{
	print "Please provide projectname \n";
	exit;
}
if(!$projectname)
{
	print "Projectname is mandatory \n";
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
if(!$db)
{
	print "Database is mandatory\n";
	exit;
}

$db=~ s/^\s+|\s+$//g;
my $database="/data/ccmdb/$db/";
my $dbbmloc="/data/ccmbm/$db/";
#my $dbbmloc="/u/kkdaadhi/ccm_wa/$db/";
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
my $mr_number;
my @patchbinarylist;
my $cr;
my %hash;
my @consumreadme;
my @task_numbers;
my @uniqbinlist;
@crs=split(/,/,$crs);
print "The following list of CRs to the included in the patch:@crs\n";
# /* Global Environment Variables ******* /
sub main()
{
		start_ccm();
		getTasksnReadme();
		reconfigure_project();
		constructReadme();
		ccm_stop();
}
sub constructReadme()
{
			$max=~ s/^\s+|\s+$//g;
			open OP,"+> patchnumber.txt";
			print OP $patch_number;
			close OP;
			open OP,"+>$patchnumber\_README.txt";
			print OP "CREATED:\n";
			print OP "TASKS:$tasklist\n";
			print OP "@confixes\n";
			print OP "@uniqbinlist\n";
			print OP "TO INSTALL AND UNINSTALL:\nRefer Patch Release Note\n";
			print OP "PRE-REQUISITE PATCHES:\nPATCHES SUPERSEDED BY THIS PATCH:\n";
			print OP "SUMMARY OF CHANGES AND AREAS AFFECTED:@consummary\nISSUES: None";
			close OP;
			`./updatePatchREADME.ksh XV $patchnumber\_README.txt`;
			#move("DSA_$patchnumber\_README.txt","$patchnumber\_README.txt");
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
		@task_numbers=`$CCM query "is_associated_task_of(cvtype='problem' and problem_number='$cr')" -u -f "%task_number"`;
		foreach $task_number(@task_numbers)
		{
			$task_number=~ s/^\s+|\s+$//g;
			print "TASKNUMBER is: $task_number \n";
			push(@tasks,$task_number);
		}
		($synopsis)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%problem_synopsis"`;
		($problem_number)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%problem_number"`;
		($requesttype)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%request_type"`;
		($severity)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%severity"`;
		($priority)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%priority"`;
		($resolver)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%resolver"`;
		$synopsis=~ s/^\s+|\s+$//g;
		$problem_number=~ s/^\s+|\s+$//g;
		$requesttype=~ s/^\s+|\s+$//g;
		$severity=~ s/^\s+|\s+$//g;
		$resolver=~ s/^\s+|\s+$//g;
		$task_synopsis=~ s/^\s+|\s+$//g;
		$task_resolver=~ s/^\s+|\s+$//g;
		$priority=~ s/^\s+|\s+$//g;
		print "$cr#$synopsis#$requesttype#$severity#$resolver#$priority\n";
		print "$task_number#$task_synopsis#$task_resolver#$synopsis\n";
		print CRRESOLV "$cr#$synopsis#$requesttype#$severity#$resolver#$priority\n";
		print TASKINF "$task_number#$task_synopsis#$task_resolver\n";
		print SYNOP "CR$cr $synopsis\n";
		#fetch readme
		`$CCM query "cvtype=\'problem\' and problem_number=\'$cr\'"`;
  	$patch_readme=`$CCM query -u -f %patch_readme`;

		print "Patch Readme is: $patch_readme \n";

  	if($patch_readme =~ /N\/A/)
  	{
  		print "The following CR: $cr doesn't have a README \n";
  	}
  	else
  	{
   		open OP1,"+> $Bin/$problem_number\_README.txt";
  		print OP1 $patch_readme;
  		close OP1;
  		`dos2unix $Bin/$problem_number\_README.txt 2>&1 1>/dev/null`;
  		@fixes=`sed -n '/FIXES:/,/AFFECTS/ p' $problem_number\_README.txt  | sed '\$ d' | sed '/^\$/d'`;
			push(@confixes,@fixes);
  		@PatchFiles=`sed -n '/AFFECTS:/,/TO/ p' $problem_number\_README.txt  | sed '\$ d' | sed '/^\$/d'`;
    	push(@patchbinarylist,@PatchFiles);
    	@summary=`sed -n '/AFFECTED:/,/ISSUES/ p' $problem_number\_README.txt  | sed '\$ d' | grep -v 'AFFECTED:' | grep -v 'ISSUES' | sed '/^\$/d'`;
    	push(@consummary,@summary);
		}
	}
		open OP,"+> $Bin/consummary.txt";
		print OP @consummary;
		close OP;
		open OP,"+> $Bin/confixes.txt";
		print OP @confixes;
		close OP;
		@sortedtasks = sort {$b <=> $a} @tasks;
		#@dsatasks=join("\n", map { 'DSA_' . $_ } @tasks);
		$tasklist=join(",",@sortedtasks);
		($min, $patchnumber) = minmax @tasks;
		print "$patchnumber is the patchnumber \n";
		open OP,"+> $Bin/contasks.txt";
		print OP $tasklist;
		close OP;
		@uniqbinlist = do { my %seen; grep { !$seen{$_}++ } @patchbinarylist};
		open OP, "+> $Bin/patchbinarylist.txt";
		print OP @uniqbinlist;
		close OP;
		close SUMM;
		close SYNOP;
		close CRRESOLV;
		close TASKINF;
}

sub reconfigure_project()
{
	$ccmworkarea=`$CCM wa -show -recurse $projectname`;
	($temp,$workarea)=split(/'/,$ccmworkarea);
	$workarea=~ s/^\s+|\s+$//g;
	$folder=~ s/^\s+|\s+$//g;
	print "Tasklist is: $tasklist and Foldername is: $folder\n";
	`$CCM folder -modify -add_task $tasklist $folder 2>&1 1>$Bin/task_addition_$projectname.log`;
	umask 002;
	$projectname=~ s/^\s+|\s+$//g;
	`$CCM reconfigure -rs -r -p $projectname 2>&1 1>$Bin/reconfigure_$projectname.log`;
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
