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
my $database="/data/ccmdb/provident/";
my $dbbmloc="/data/ccmbm/provident/";

my $hostname = hostname;
my $hostplatform;
my $gmake;
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
# /* Global Environment Variables ******* /
sub main()
{
		start_ccm();
		fetchdevinfo();
		ccm_stop();
}

sub fetchdevinfo()
{
		my @taskinfo=`$CCM rp -show all_tasks $devprojectname:project:1`;
		print "Task information of the project: @taskinfo\n";
		my @objectlist=`$CCM query "(is_member_of('$devprojectname'))"`;
		print "Object information: @objectlist\n";
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
