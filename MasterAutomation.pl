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

$result=GetOptions("devproject=s"=>\$devprojectname,"folder=s"=>\$folder,"crs=s"=>\$crs);
#$result=GetOptions("devproject=s"=>\$devprojectname,"javaproject=s"=>\$javaprojectname,"folder=s"=>\$folder,"crs=s"=>\$crs);
if(!$result)
{
	print "Please provide devprojectname \n";
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
#my $mailto='kiran.daadhi@evolving.com';
my %hash;
#$destdir="/u/kkdaadhi/Tertio_Deliverable";
my $readmeIssue;

@crs=split(/,/,$crs);
print "The following list of CRs to the included in the patch:@crs\n";
# /* Global Environment Variables ******* /
sub main()
{	
		start_ccm();
		getTasksnReadme();
		reconfigure_devproject();
		ccm_stop();		
}
sub getTasksnReadme()
{	
	open SYNOP,"+>$Bin/synopsis.txt";
	open SUMM,"+> $Bin/summary.txt";
	open MR,"+> $Bin/mrnumber.txt";
	foreach my $cr(@crs)
	{
		$cr=~ s/^\s+|\s+$//g;
		$task_number=`$CCM query "is_associated_task_of(cvtype='problem' and problem_number='$cr')" -u -f "%task_number"`;
		$task_number=~ s/^\s+|\s+$//g;
		push(@tasks,$task_number);		
		#get mrnumber
		($mr_number,$synopsis,$summary)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%MRnumber,%problem_synopsis,%problem_description"`;
		print SYNOP "CR$cr $synopsis\n";
		print SUMM "CR$cr $summary\n";
		$mr_number=~ s/^\s+|\s+$//g;
		print MR "$mr_number";
		#fetch readme
		`$CCM query "cvtype=\'problem\' and problem_number=\'$cr\'"`;
    	$patch_number=`$CCM query -u -f %patch_number`;
    	$patch_readme=`$CCM query -u -f %patch_readme`;
    	$patch_number=~ s/^\s+|\s+$//g;
    
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
    	}
	}
	close SYNOP;
	close SUMM;
	close MR;
	$tasklist=join(",",@tasks);
	$formattsks=join("PROV_",@tasks);
	open OP,"+>$Bin/formattsks.txt";
	print OP $formattsks;
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