#!/usr/bin/perl
# Tertio 7.6 Build Script
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
my $binarylist="$Bin/fileplacement.fp";
my $javabinarylist="$Bin/javabinaries.fp";
my $hostname = hostname;
my $hostplatform;
my @crresolv;
my $cr;
sub main()
{
	transition_cr();
}
sub transition_cr()
{
	open OP,"<$Bin/crresolv.txt";
	@crresolv=<OP>;
	close OP;
	foreach (@crresolv)
	{
		($crnumber)=split(/#/,$_);
		print "CR number is: $crnumber \n";
		$crnumber =~ s/^\s+|\s+$//g;
		my	@crtransition_log=`perl ModifyCRTransistion.pl $crnumber Patch_test`;
		print "CR Transition log: @crtransition_log \n";		 
	}
}
main();