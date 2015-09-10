#!/usr/bin/perl
# DSA Transition Script
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
my $crnumber;
my $result=GetOptions("crlist=s"=>\$crlist);
if(!$result)
{
	print "Please provide the CRs\n";
	exit;
}
if(!$crlist)
{
	print "Please provide the CRlist\n";
	exit;
}
@crlist=split(/,/,$crlist);
sub main()
{
	transition_cr();
}
sub transition_cr()
{
	foreach (@crlist)
	{
		($crnumber)=$_;
		print "CR number is: $crnumber \n";
		$crnumber =~ s/^\s+|\s+$//g;
		my	@crtransition_log=`perl ModifyCRTransistion.pl $crnumber Patch_test`;
		print "CR Transition log: @crtransition_log \n";
	}
}
main();
