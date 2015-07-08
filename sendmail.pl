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
my $attachment="/tmp/logs.zip";
sub main()
{
	send_email('subject','$attachment');
}
sub send_email()
{
	($subject,$attachment)=@_;
	print "\$attachment value is: $attachment \n";
	system("/usr/bin/mutt -s '$subject' $mailto -a $attachment < /dev/null");
}
main();