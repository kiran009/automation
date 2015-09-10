#!/usr/bin/perl
# DSA send E-mail Script
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
	open OP,"<$Bin/con_crresolv.txt";
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
	open OP,"<$Bin/con_taskinfo.txt";
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
