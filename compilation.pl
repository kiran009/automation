#!/usr/bin/perl
# Tertio Build Script
use Cwd;
use File::Path;
use File::Find;
use File::Basename;
use Getopt::Long;
use File::Copy;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Sys::Hostname;

#/************ Setting Environment Variables *******************/
my $database="/data/ccmdb/provident/";
my $dbbmloc="/data/ccmbm/provident/";

my $hostname = hostname;
my $hostplatform;
my $gmake;
if($hostname !~ /pesthp2/)
{
	# On HPUX, CCM client doesn't exist, ignore setting this environment there
	$ENV{'CCM_HOME'}="/opt/ccm71";
	$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
	$CCM="$ENV{'CCM_HOME'}/bin/ccm";
}
if($hostname !~ /pedhp2/)
{
	# On HPUX, CCM client doesn't exist, ignore setting this environment there
	$ENV{'CCM_HOME'}="/opt/ccm71";
	$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
	$CCM="$ENV{'CCM_HOME'}/bin/ccm";
}
if($hostname !~ /pedhp1/)
{
	# On HPUX, CCM client doesn't exist, ignore setting this environment there
	$ENV{'CCM_HOME'}="/opt/ccm71";
	$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
	$CCM="$ENV{'CCM_HOME'}/bin/ccm";
}
if($hostname =~ /pedlinux5/)
{	$hostplatform="linas5"; $gmake='/usr/bin/gmake';}
if($hostname =~ /pedlinux2/)
{	$hostplatform="linas4"; $gmake='/usr/bin/gmake';}
if($hostname =~ /pedlinux1/)
{	$hostplatform="linas3"; $gmake='/usr/bin/gmake';}
elsif($hostname =~ /pedlinux6/)
{	$hostplatform="rhel6";$gmake='/usr/bin/gmake';}
elsif($hostname =~ /pedsun2/)
{	$hostplatform="sol10";$gmake='/usr/bin/gmake';}
elsif($hostname =~ /pedsun3/)
{	$hostplatform="sol9";$gmake='/usr/bin/gmake';}
elsif($hostname =~ /pesthp2/)
{	$hostplatform="hpiav3";$gmake='/usr/local/bin/gmake';}
elsif($hostname =~ /pedhp1/)
{	$hostplatform="hppa";$gmake='/usr/local/bin/gmake';}
elsif($hostname =~ /pedhp2/)
{	$hostplatform="hpia";$gmake='/usr/local/bin/gmake';}

$result=GetOptions("devproject=s"=>\$devprojectname);
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
$devprojectname=~ s/^\s+|\s+$//g;
my $workarea="$dbbmloc/$devprojectname";
umask 002;
# /* Global Environment Variables ******* /
sub main()
{
		if(($hostname !~ /pesthp2/) || ($hostname !~ /pedhp2/) || ($hostname !~ /pedhp1/))
		{
			start_ccm();
		}
		compile();
		if(($hostname !~ /pesthp2/) || ($hostname !~ /pedhp2/) || ($hostname !~ /pedhp1/))
		{
			ccm_stop();
		}
}

sub compile()
{
	if($devprojectname =~ /Java/)
	{
		chdir "$workarea/Provident_Java";
	}
	else
	{
		chdir "$workarea/Provident_Dev";
	}
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
