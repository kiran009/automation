#!/usr/bin/perl
# Tertio 7.6 Developer information
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
my $mailto="kiran.daadhi\@evolving.com srikanth.bhaskar\@evolving.com";
$ENV{'CCM_HOME'}="/opt/ccm71";
$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
$CCM="$ENV{'CCM_HOME'}/bin/ccm";

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
		`zip -r $devprojectname\.zip gmake_$devprojectname\*log taskobjects.txt`;
		send_email("Developer Information on project $devprojectname","$devprojectname\.zip");
}
sub send_email()
{
	($subject,$attachment)=@_;
	print "\$attachment value is: $attachment \n";
	system("/usr/bin/mutt -s '$subject' $mailto -a $attachment < /dev/null");
}
sub fetchdevinfo()
{
		open TASKDETAIL, "+> $Bin/taskobjects.txt";
		print TASKDETAIL "7.6.3";
		fetchinfo('7.6.3');
		print TASKDETAIL "7.6.2";
		fetchinfo('7.6.2');
		close TASKDETAIL;
}
sub fetchinfo()
{
	my($release)=@_;
	open FETCH,"<$release\_taskinfo.txt";
	my @tasklist=<FETCH>;
	close FETCH;
	foreach(@tasklist)
	{
		my ($tasknumber,@temp)=split(/#/,$_);
		my @objlist=`$CCM task -sh obj $tasknumber`;
		print TASKDETAIL "Objects in TASK: $tasknumber are:\n @objlist \n";
		print TASKDETAIL "************"
	}
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
