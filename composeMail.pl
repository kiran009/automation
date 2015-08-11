#!/usr/bin/perl
# Tertio 7.6 send E-mail Script
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

@months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year+=1900;
my $dt="$mday $months[$mon] $year\n";
my $dtformat="$year$months[$mon]$mday$hour$min";
my $FILE;
#my $result=GetOptions("buildnumber=s"=>\$build_number);
sub main()
{
	crtnsndMail();
}
sub crtnsndMail()
{
	open BN,"<$Bin/build_number.txt";
	$build_number=<BN>;
	close BN;
	open OP, "<$Bin/location.txt";
	@location=<OP>;
	close OP;
	open OP,"<$Bin/mrnumber.txt";
	$mrnumber=<OP>;
	close OP;
	open OP,"<$Bin/formattsks.txt";
	@formattsks=<OP>;
	my @uniqtasks= do { my %seen; grep { !$seen{$_}++ } @formattsks};
	my @uniqtsks=grep(s/\s*$//g,@uniqtasks);
	my @uniqtsks=grep /\S/,@uniqtsks;
	@fformattsks=map{"$_\n"} @uniqtsks;
	$formattedtsks=join(",",@formattsks);
	$formattedtsks =~ s/[\n\r]//g;
	close OP;
	$mrnumber=~ s/^\s+|\s+$//g;
	@location_explode=map{"$_<br/>"} @location;
	open ($FILE, "+> $Bin/releasenotes.html");
	print $FILE "<html><head><style>table {border: 1 solid black; white-space: nowrap; font: 12px arial, sans-serif;} body,td,th,tr {font: 12px arial, sans-serif; white-space: nowrap;}</style></head><body>";
	print $FILE "<table width=\"100%\" border=\"1\"<br/>";
	print $FILE "<tr><b><td>Product</td></b><td colspan=\'2\'>Tertio</td></tr><br/>";
	print $FILE "<tr><b><td>Release</td></b><td colspan=\'2\'>$mrnumber</td></tr><br/>";
	print $FILE "<tr><b><td>Build Number</td></b><td colspan=\'2\'>$build_number</td></tr><br/>";
	print $FILE "<tr><b><td>Release Type</td></b><td colspan=\'2\'>Maintenance Release</td></tr><br/>";
	print $FILE "<tr><b><td>Location</td></b><td colspan=\'2\'>@location_explode</td></tr><br/>";
	print $FILE "<tr><b><td>Build Date</td></b><td colspan=\'2\'>$dtformat</td></tr><br/>";
	print $FILE "<tr><b><td>Major changes in the new build</td></b><td colspan=\'2\'>BUG FIXES</td></tr><br/>";
	print $FILE "<tr><b><td>TOME</td></b><td>3.0.0</td><td>BUILD19</td></tr><br/>";
	print $FILE "<tr><b><td>Tertio ADK</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>CAF</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>Dashboard SDK</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>DDA Protocol Version</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>Menu Server Extension</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>SMS payload STK</td></b><td>-</td><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>RM CDK</td><td>-</td></b><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>PE CDK</td><td>-</td></b><td>-</td></tr><br/>";
	print $FILE "<tr><b><td>Has the developer documentation been updated?</td></b><td colspan=\"2\">N/A</td></tr></table><br/>";
	print $FILE "<b>Installation instructions: </b><br/>";
	print $FILE "Same as previous Tertio Maintenance Release<br/><br/>";
	print $FILE "<b>Additional information about the changes:</b>N/A<br /><b>The Resolved CRs are:</b><br/>";
	print $FILE "<b><table width=\"100%\" border=\"1\">";
	print $FILE "<tr><b><td>CR ID</td><td>Synopsis</td><td>Request Type</td><td>Severity</td><td>Resolver</td><td>Priority</td></tr><br/>";
	crresolv('7.6.3');
	crresolv('7.6.2');
	print $FILE "</table><br/>";
	print $FILE "<b>The checked in tasks since the last build are:</b><br/>";
	print $FILE "<b><table width=\"100%\" border=\"1\">";
	print $FILE "<tr><b><td>Task ID</td><td>Synopsis</td><td>Resolver</td></tr>";
	taskinfo('7.6.3');
	taskinfo('7.6.2');
	print $FILE "</table><br/>";
	print $FILE "<b>Note:</b> To install Tertio $mrnumber, please use the latest PatchManager<br/></body></html>";
	close $FILE;
}
sub crresolv()
{
	undef @taskinfo;
	undef @crresolv;
	undef @synopsis;

	my ($releasenumber)=@_;
	open OP,"<$Bin/$releasenumber\_synopsis.txt";
	@synopsis=<OP>;
	close OP;
	open OP,"<$Bin/$releasenumber\_crresolv.txt";
	@crresolv=<OP>;
	close OP;
	print $FILE "<tr><b><td colspan='6'>$releasenumber</td></tr>";
	foreach $cr(@crresolv)
	{
		($crid,$synopsis,$requesttype,$severity,$resolver,$priority)=split(/#/,$cr);
		print $FILE "<tr><b><td>$crid</td><td>$synopsis</td><td>$requesttype</td><td>$severity</td><td>$resolver</td><td>$priority</td></tr>";
	}
}
sub taskinfo()
{
	undef @taskinfo;
	my ($releasenumber)=@_;
	open OP,"<$Bin/$releasenumber\_taskinfo.txt";
	@taskinfo=<OP>;
	close OP;
	print $FILE "<tr><b><td colspan='6'>$releasenumber</td></tr>";
	foreach $tsk(@taskinfo)
	{
		($task_number,$task_synopsis,$task_resolver)=split(/#/,$tsk);
		print $FILE "<tr><b><td>$task_number</td><td>$task_synopsis</td><td>$task_resolver</td></tr><br/>";
	}

}
main();
