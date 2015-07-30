#!/usr/bin/perl
use Cwd;
use File::Path;
use File::Find;
use File::Basename;
use Switch;
use Getopt::Long;

#/************ Setting Environment Variables *******************/
$result=GetOptions("db=s"=>\$database);
$ENV{'CCM_HOME'}="/opt/ccm71";
$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
$CCM="$ENV{'CCM_HOME'}/bin/ccm";
if(!$database)
{
	print "Database value is not passed. Please provide database name. Ex: perl database_dwell.pl -db /data/ccmdb/training_peg \n";
	exit;
}
$DATABASE=basename $database;
print "DATABASE : $DATABASE \n";
main();
sub main()
{
	start_ccm();
	fetch_projects();
	ccm_stop();
	exit;
}
sub fetch_projects()
{
	my @projectlist=`$CCM query -type project -u -f "%objectname"`;
	open PROJ, "+> projectlist_$DATABASE";
	print PROJ @projectlist;
	print @projectlist;
	close PROJ;
	my @releaselist=`$CCM release -l`;
	open REL,"+> releases_$DATABASE";
	print REL @releaselist;
	close REL;
	open BL,"+> baseline_$DATABASE";
	open CSV,"+> releasecsv_$DATABASE\.csv";
	print CSV "Release, Baseline Exists, Number of Baselines\n";
	foreach my $release(@releaselist)
	{
		$release=~ s/^\s+|\s+$//g;
		my @baselinelist=`$CCM baseline -l -release $release`;
		my $scoutput=scalar @baselinelist;
		if($scoutput == 0)
		{
			print BL "\nNo Baselines exist for release:\t $release\n";
			print BL "**********************";
			print CSV "$release,No,$scoutput\n";
		}
		else
		{
			print BL "\nBaselines for release:\t $release\n @baselinelist\n Number of baselines: $scoutput\n";
			print BL "**********************";
			print CSV "$release,Yes,$scoutput\n";
		}

	}
	close CSV;
	close BL;
	open CONFLICTS, "+> conflicts_$DATABASE";
	foreach my $project(@projectlist)
	{
		$project=~ s/^\s+|\s+$//g;
	my @conflicts=`$CCM conflicts $project`;
	my $scconflicts=scalar @conflicts;
	if($scconficts == 0)
	{
			print CONFLICTS "\nConflicts in the project $project are: @conflicts \n";
			print CONFLICTS "*************";
		}
		else
		{
			print CONFLICTS "\nConflicts in the project $project are: @conflicts\n Number of conflicts: $scconficts\n";
			print CONFLICTS "*************";
		}
	}
	close CONFLICTS;
	my $runninguser=`id -u -n`;
	#`zip -r $DATABASE\.zip releasecsv_$DATABASE\.csv projectlist_$DATABASE releases_$DATABASE baseline_$DATABASE`;
	`zip -r $DATABASE\.zip releasecsv_$DATABASE\.csv projectlist_$DATABASE releases_$DATABASE baseline_$DATABASE conflicts_$DATABASE`;
	send_email("$DATABASE information","$DATABASE\.zip",$runninguser);
}
sub start_ccm()
{
	open(ccm_addr,"$ENV{'CCM_HOME'}/bin/ccm start -d $database -m -q -h ccmuk1 -nogui |");
	$ENV{'CCM_ADDR'}=<ccm_addr>;
	close(ccm_addr);
}
sub send_email()
{
	($subject,$attachment,$resolver)=@_;
	system("/usr/bin/mutt -s '$subject' '$resolver\@evolving.com' -c kiran.daadhi\@evolving.com -c hari.annamalai\@evolving.com -a '$attachment' < /dev/null");
}
sub ccm_stop()
{
	open(ccm_addr,"$ENV{'CCM_HOME'}/bin/ccm stop |");
	close(ccm_addr);
}
