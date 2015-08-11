#!/usr/bin/perl
# DSA Build Script
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
my $hostname = hostname;
my $hostplatform;
my $gmake;
my $devprojectname;
my $hostplatform;
if($hostname !~ /pesthp2/)
{
	# On HPUX, CCM client doesn't exist, ignore setting this environment there
	$ENV{'CCM_HOME'}="/opt/ccm71";
	$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
	$CCM="$ENV{'CCM_HOME'}/bin/ccm";
}
if($hostname =~ /pedlinux5/)
{	$hostplatform="linas5"; $gmake='/usr/bin/gmake';}
elsif($hostname =~ /pedlinux6/)
{	$hostplatform="rhel6";$gmake='/usr/bin/gmake';}
elsif($hostname =~ /pedsun2/)
{	$hostplatform="sol10";$gmake='/usr/bin/gmake';}
elsif($hostname =~ /pesthp2/)
{	$hostplatform="hpiav3";$gmake='/usr/local/bin/gmake';}

$result=GetOptions("devproject=s"=>\$devprojectname,"database=s"=>\$db);
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
if(!$db)
{
	print "Database name is mandatory \n";
	exit;
}
$devprojectname=~ s/^\s+|\s+$//g;
$db=~ s/^\s+|\s+$//g;
my $database="/data/ccmdb/$db/";
#my $dbbmloc="/u/kkdaadhi/ccm_wa/$db/";
my $dbbmloc="/data/ccmbm/$db/";
my $workarea;
if($database =~ /dsa/)
{
	$workarea="$dbbmloc/$devprojectname/DSA_MS_Dev";
}
umask 002;
# /* Global Environment Variables ******* /
sub main()
{
		start_ccm();
		compile();
		ccm_stop();
}

sub compile()
{
	chdir "$workarea";
	umask 002;
	`$gmake clean all 2>&1 1>$Bin/gmake_$devprojectname\_$hostplatform.log`;
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
