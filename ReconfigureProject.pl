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
my ($min, $max) = minmax @numbers;

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

$result=GetOptions("project=s"=>\$projectname,"database=s"=>\$db);
if(!$result)
{
	print "Please provide devprojectname \n";
	exit;
}
if(!$projectname)
{
	print "Projectname is mandatory \n";
	exit;
}
if(!$db)
{
	print "Database is mandatory\n";
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
@crs=split(/,/,$crs);
print "The following list of CRs to the included in the patch:@crs\n";
# /* Global Environment Variables ******* /
sub main()
{
		start_ccm();
		reconfigure_project();
		ccm_stop();
}
sub reconfigure_project()
{
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
	# Nullify the location.txt file
	`> $Bin/location.txt`;
}
main();
